#!/usr/bin/env python3
"""Verificación estática ligera de Dart, sin SDK.

No sustituye a `dart analyze` —eso lo hace CI— pero atrapa antes las tres
clases de error que más veces han roto una compilación en este proyecto:

1. **Delimitadores desbalanceados** en archivos largos de contenido, donde un
   paréntesis perdido entre cadenas con comillas tipográficas es difícil de
   ver a simple vista.
2. **Imports que no resuelven** a un archivo existente.
3. **Imports que no se usan** (ruido que `flutter analyze` marca y que
   conviene limpiar antes de subir).

Además informa del tamaño del proyecto.

Uso:
    python3 tool/static_check.py
"""

from __future__ import annotations

import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")
TEST = os.path.join(ROOT, "test")

errors: list[str] = []
warnings: list[str] = []


def dart_files(*roots: str) -> list[str]:
    out = []
    for root in roots:
        for dirpath, _dirnames, filenames in os.walk(root):
            for name in sorted(filenames):
                if name.endswith(".dart"):
                    out.append(os.path.join(dirpath, name))
    return sorted(out)


def strip_code(src: str) -> str:
    """Elimina comentarios y cadenas, dejando solo estructura."""
    out = []
    i = 0
    n = len(src)
    while i < n:
        c = src[i]
        # Comentario de línea
        if c == "/" and i + 1 < n and src[i + 1] == "/":
            while i < n and src[i] != "\n":
                i += 1
            continue
        # Comentario de bloque
        if c == "/" and i + 1 < n and src[i + 1] == "*":
            i += 2
            while i + 1 < n and not (src[i] == "*" and src[i + 1] == "/"):
                i += 1
            i += 2
            continue
        # Cadenas triples
        if src.startswith("'''", i) or src.startswith('"""', i):
            quote = src[i:i + 3]
            i += 3
            while i < n and not src.startswith(quote, i):
                if src[i] == "\\":
                    i += 1
                i += 1
            i += 3
            continue
        # Cadenas simples
        if c in "'\"":
            quote = c
            i += 1
            while i < n and src[i] != quote:
                if src[i] == "\\":
                    i += 2
                    continue
                if src[i] == "$" and i + 1 < n and src[i + 1] == "{":
                    # Interpolación: se conserva entera, porque lleva
                    # delimitadores que sí deben cuadrar.
                    i += 1
                    depth = 0
                    while i < n:
                        ch = src[i]
                        if ch == "{":
                            depth += 1
                        elif ch == "}":
                            depth -= 1
                        out.append(ch)
                        i += 1
                        if depth == 0:
                            break
                    continue
                i += 1
            i += 1
            continue
        out.append(c)
        i += 1
    return "".join(out)


def check_balance(path: str) -> None:
    code = strip_code(open(path, encoding="utf-8").read())
    pairs = {")": "(", "]": "[", "}": "{"}
    stack = []
    line = 1
    for ch in code:
        if ch == "\n":
            line += 1
        elif ch in "([{":
            stack.append((ch, line))
        elif ch in ")]}":
            if not stack:
                errors.append(
                    f"{rel(path)}:{line}: '{ch}' sin apertura"
                )
                return
            opened, opened_line = stack.pop()
            if opened != pairs[ch]:
                errors.append(
                    f"{rel(path)}:{line}: se esperaba cerrar '{opened}' "
                    f"abierto en la línea {opened_line}, llegó '{ch}'"
                )
                return
    if stack:
        opened, opened_line = stack[-1]
        errors.append(
            f"{rel(path)}: falta cerrar '{opened}' abierto en la línea "
            f"{opened_line}"
        )


def rel(path: str) -> str:
    return os.path.relpath(path, ROOT)


TOP_LEVEL_RE = re.compile(
    r"^(?:abstract\s+|sealed\s+|final\s+|base\s+)*"
    r"(?:class|enum|mixin|extension|typedef)\s+(\w+)",
    re.M,
)
TOP_VAR_RE = re.compile(r"^(?:const|final)\s+[^=;\n]*?(\w+)\s*=", re.M)
TOP_FN_RE = re.compile(r"^[\w<>,\s\?\[\]]+\s(\w+)\s*\([^)]*\)\s*(?:=>|\{)",
                       re.M)


def exported_names(path: str) -> set[str]:
    src = open(path, encoding="utf-8").read()
    names = set(TOP_LEVEL_RE.findall(src))
    names |= set(TOP_VAR_RE.findall(src))
    names |= set(TOP_FN_RE.findall(src))
    return {n for n in names if n and not n.startswith("_")}


def check_imports(path: str, all_files: set[str]) -> None:
    src = open(path, encoding="utf-8").read()
    body = strip_code(src)
    base = os.path.dirname(path)
    for m in re.finditer(r"import\s+'([^']+)'", src):
        target = m.group(1)
        if target.startswith("package:") or target.startswith("dart:"):
            continue
        resolved = os.path.normpath(os.path.join(base, target))
        if resolved not in all_files:
            errors.append(f"{rel(path)}: import sin destino: {target}")
            continue
        names = exported_names(resolved)
        if not names:
            continue
        # Un archivo que solo aporta extensiones se usa a través de sus
        # miembros (`.label`), no de su nombre: no se puede detectar así.
        if re.search(r"^extension\s", open(resolved, encoding="utf-8").read(),
                     re.M):
            continue
        if not any(re.search(rf"\b{re.escape(n)}\b", body) for n in names):
            warnings.append(
                f"{rel(path)}: import posiblemente sin usar: {target}"
            )


def check_placeholders(path: str) -> None:
    src = open(path, encoding="utf-8").read()
    for pattern, label in [
        (r"\bTODO\b", "TODO"),
        (r"\bFIXME\b", "FIXME"),
        (r"throw\s+UnimplementedError", "UnimplementedError"),
    ]:
        if re.search(pattern, src):
            warnings.append(f"{rel(path)}: contiene {label}")


def main() -> int:
    print("=" * 66)
    print("Verificación estática de Dart — Probability Master")
    print("=" * 66)
    files = dart_files(LIB, TEST)
    all_files = {os.path.normpath(f) for f in files}
    total_lines = 0
    for path in files:
        with open(path, encoding="utf-8") as fh:
            total_lines += sum(1 for _ in fh)
        check_balance(path)
        check_imports(path, all_files)
        check_placeholders(path)

    lib_files = [f for f in files if f.startswith(LIB)]
    test_files = [f for f in files if f.startswith(TEST)]
    print(f"\nArchivos Dart: {len(files)} "
          f"({len(lib_files)} en lib, {len(test_files)} en test)")
    print(f"Líneas totales: {total_lines:,}".replace(",", " "))

    if warnings:
        print(f"\nAvisos ({len(warnings)}):")
        for w in warnings:
            print(f"    · {w}")
    if errors:
        print(f"\nERRORES ({len(errors)}):")
        for e in errors:
            print(f"    ✗ {e}")
        return 1
    print("\n✓ Sin errores estructurales")
    return 0


if __name__ == "__main__":
    sys.exit(main())
