#!/usr/bin/env python3
"""Verificación del contenido sin SDK de Flutter.

Hace cuatro cosas que, juntas, sustituyen a poder ejecutar la app:

1. **Recalcula todas las cifras declaradas** (`ContentFigure`) con la réplica
   del motor en Python, de forma independiente del código Dart.
2. **Comprueba la integridad referencial**: que toda confusión citada exista,
   que todo remedio apunte a una lección o experimento real, que todo
   predicado de construcción esté implementado y que no haya ids duplicados.
3. **Comprueba la promesa del catálogo**: que cada confusión del catálogo sea
   producida por al menos un distractor. Una confusión que ningún ejercicio
   puede detectar es contenido muerto.
4. **Comprueba que el texto no cite marcas `{{…}}` inexistentes** en su
   archivo.

Uso:
    python3 tool/verify_content.py
Devuelve 0 si todo pasa, 1 si algo falla.
"""

from __future__ import annotations

import glob
import os
import re
import sys
from fractions import Fraction

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import probability_core as core  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONTENT = os.path.join(ROOT, "lib", "data", "content")

errors: list[str] = []
warnings: list[str] = []


def fail(msg: str) -> None:
    errors.append(msg)


def warn(msg: str) -> None:
    warnings.append(msg)


def read(path: str) -> str:
    with open(path, encoding="utf-8") as fh:
        return fh.read()


def all_content_files() -> list[str]:
    return sorted(glob.glob(os.path.join(CONTENT, "*.dart")))


# ---------------------------------------------------------------------
# 1 · Cifras
# ---------------------------------------------------------------------
FIGURE_RE = re.compile(
    r"ContentFigure\s*\((?P<body>.*?)\)\s*,\s*\n", re.S
)
FIELD_RE = {
    "id": re.compile(r"id:\s*'([^']+)'"),
    "fn": re.compile(r"fn:\s*'([^']+)'"),
    "args": re.compile(r"args:\s*\[([^\]]*)\]"),
    "format": re.compile(r"format:\s*FigureFormat\.(\w+)"),
    "label": re.compile(r"label:\s*'([^']*)'"),
}


def parse_figures():
    figures = []
    for path in all_content_files():
        src = read(path)
        for m in FIGURE_RE.finditer(src):
            body = m.group("body")
            fid = FIELD_RE["id"].search(body)
            fn = FIELD_RE["fn"].search(body)
            args = FIELD_RE["args"].search(body)
            fmt = FIELD_RE["format"].search(body)
            label = FIELD_RE["label"].search(body)
            if not (fid and fn and args is not None):
                continue
            raw_args = [a.strip() for a in args.group(1).split(",") if a.strip()]
            try:
                parsed = [int(a) for a in raw_args]
            except ValueError:
                fail(f"{os.path.basename(path)}: args no enteros en "
                     f"{fid.group(1)}")
                continue
            figures.append({
                "file": os.path.basename(path),
                "id": fid.group(1),
                "fn": fn.group(1),
                "args": parsed,
                "format": fmt.group(1) if fmt else "fraction",
                "label": label.group(1) if label else "",
            })
    return figures


def check_figures(figures):
    print(f"\n[1] Cifras declaradas: {len(figures)}")
    ok = 0
    for f in figures:
        try:
            value = core.evaluate(f["fn"], f["args"])
        except Exception as exc:  # noqa: BLE001
            fail(f"ficha {f['id']} ({f['fn']}): {exc}")
            continue
        if isinstance(value, Fraction):
            if not (0 <= value <= 1) and f["fn"] != "literal":
                fail(f"ficha {f['id']} ({f['fn']}): probabilidad fuera de "
                     f"[0,1] → {value}")
                continue
            shown = (f"{core.format_fraction(value)} = "
                     f"{float(value):.6f} = {core.format_percent(value, 2)}")
        else:
            if value < 0:
                fail(f"ficha {f['id']}: conteo negativo")
                continue
            shown = f"{value:,}".replace(",", " ")
        ok += 1
        print(f"    {f['id']:<22} {f['fn']:<20} {shown}")
    print(f"    → {ok}/{len(figures)} cifras recalculadas correctamente")
    return ok


# ---------------------------------------------------------------------
# 2 · Integridad referencial
# ---------------------------------------------------------------------
def collect(pattern: str, path: str) -> list[str]:
    return re.findall(pattern, read(path))


def check_references():
    print("\n[2] Integridad referencial")

    misc_src = read(os.path.join(CONTENT, "misconceptions_data.dart"))
    catalog = re.findall(r"^\s*id:\s*'([a-z_0-9]+)',", misc_src, re.M)
    print(f"    Confusiones en el catálogo: {len(catalog)}")
    if len(catalog) != len(set(catalog)):
        fail("hay ids de confusión duplicados")

    lesson_ids = []
    for f in ["lessons_m1.dart", "lessons_m2.dart",
              "lessons_m3.dart", "lessons_m4.dart"]:
        lesson_ids += re.findall(
            r"id:\s*'(m\d_l\d+)'", read(os.path.join(CONTENT, f))
        )
    print(f"    Lecciones: {len(lesson_ids)}")
    if len(lesson_ids) != len(set(lesson_ids)):
        fail("ids de lección duplicados")

    labs_src = read(os.path.join(CONTENT, "labs_data.dart"))
    experiment_ids = re.findall(r"id:\s*'(x\d+[a-z_0-9]*)'", labs_src)
    print(f"    Experimentos: {len(experiment_ids)}")
    if len(experiment_ids) != len(set(experiment_ids)):
        fail("ids de experimento duplicados")

    exercise_ids = []
    for f in ["exercises_m1.dart", "exercises_m2.dart",
              "exercises_m3.dart", "exercises_m4.dart"]:
        exercise_ids += re.findall(
            r"id:\s*'(m\d_e\d+)'", read(os.path.join(CONTENT, f))
        )
    print(f"    Ejercicios: {len(exercise_ids)}")
    if len(exercise_ids) != len(set(exercise_ids)):
        fail("ids de ejercicio duplicados")

    cases_src = read(os.path.join(CONTENT, "cases_data.dart"))
    case_ids = re.findall(r"id:\s*'(c\d+_[a-z]+)'", cases_src)
    print(f"    Casos: {len(case_ids)}")

    # Remedios de las confusiones
    for lid in re.findall(r"remedyLessonId:\s*'([^']+)'", misc_src):
        if lid not in lesson_ids:
            fail(f"remedyLessonId inexistente: {lid}")
    for xid in re.findall(r"remedyExperimentId:\s*'([^']+)'", misc_src):
        if xid not in experiment_ids:
            fail(f"remedyExperimentId inexistente: {xid}")

    # lessonId de los experimentos
    for lid in re.findall(r"lessonId:\s*'([^']+)'", labs_src):
        if lid not in lesson_ids:
            fail(f"experimento apunta a una lección inexistente: {lid}")

    # preferredExperimentId de las lecciones
    for f in ["lessons_m1.dart", "lessons_m2.dart",
              "lessons_m3.dart", "lessons_m4.dart"]:
        src = read(os.path.join(CONTENT, f))
        for xid in re.findall(r"preferredExperimentId:\s*'([^']+)'", src):
            if xid not in experiment_ids:
                fail(f"{f}: preferredExperimentId inexistente: {xid}")

    # misconceptionId y detects, en todos los archivos
    used_by_distractor = set()
    for path in all_content_files():
        base = os.path.basename(path)
        if base == "misconceptions_data.dart":
            continue
        src = read(path)
        for mid in re.findall(r"misconceptionId:\s*'([^']+)'", src):
            used_by_distractor.add(mid)
            if mid not in catalog:
                fail(f"{base}: misconceptionId inexistente: {mid}")
        for block in re.findall(r"detects:\s*\[([^\]]*)\]", src):
            for mid in re.findall(r"'([^']+)'", block):
                if mid not in catalog:
                    fail(f"{base}: detects con id inexistente: {mid}")
        for block in re.findall(r"targetsMisconception:\s*'([^']+)'", src):
            if block not in catalog:
                fail(f"{base}: targetsMisconception inexistente: {block}")

    # Predicados de construcción
    known_predicates = set(
        re.findall(
            r"^\s*'(\w+)',$",
            read(os.path.join(CONTENT, "sample_space_catalog.dart")),
            re.M,
        )
    )
    for f in ["exercises_m1.dart", "exercises_m2.dart",
              "exercises_m3.dart", "exercises_m4.dart"]:
        src = read(os.path.join(CONTENT, f))
        for pred in re.findall(r"predicate:\s*'([^']+)'", src):
            if pred not in known_predicates:
                fail(f"{f}: predicado no implementado: {pred}")
        for sid in re.findall(r"spaceId:\s*'([^']+)'", src):
            if sid not in known_predicates and sid not in re.findall(
                r"case '([^']+)':",
                read(os.path.join(CONTENT, "sample_space_catalog.dart")),
            ):
                fail(f"{f}: spaceId no implementado: {sid}")

    # [3] Toda confusión debe ser producida por algún distractor
    print("\n[3] Cobertura del catálogo de confusiones")
    dead = [c for c in catalog if c not in used_by_distractor]
    if dead:
        for d in dead:
            fail(f"confusión sin ningún distractor que la produzca: {d}")
    else:
        print(f"    Las {len(catalog)} confusiones tienen al menos un "
              f"distractor que las produce")

    return {
        "catalog": catalog,
        "lessons": lesson_ids,
        "experiments": experiment_ids,
        "exercises": exercise_ids,
        "cases": case_ids,
    }


# ---------------------------------------------------------------------
# 4 · Marcas {{…}}
# ---------------------------------------------------------------------
def check_markers(figures):
    print("\n[4] Marcas de cifra en el texto")
    by_file: dict[str, set[str]] = {}
    for f in figures:
        by_file.setdefault(f["file"], set()).add(f["id"])
    total = 0
    for path in all_content_files():
        base = os.path.basename(path)
        src = read(path)
        markers = set(re.findall(r"\{\{([a-zA-Z_0-9]+)\}\}", src))
        total += len(markers)
        declared = by_file.get(base, set())
        # Las fichas usadas como respuesta esperada de un ejercicio de
        # cálculo no aparecen en el texto a propósito: el estudiante debe
        # obtener el número, no leerlo.
        answers = set()
        for block in re.findall(r"NumericTarget\((.*?)\n\s{4}\)", src, re.S):
            answers.update(re.findall(r"id:\s*'([^']+)'", block))
        declared = declared - answers
        missing = markers - declared
        for m in sorted(missing):
            fail(f"{base}: la marca {{{{{m}}}}} no tiene ficha declarada")
        unused = declared - markers
        for u in sorted(unused):
            warn(f"{base}: ficha declarada y no usada en texto: {u}")
    print(f"    {total} marcas distintas comprobadas")


def main() -> int:
    print("=" * 66)
    print("Verificación de contenido — Probability Master")
    print("=" * 66)
    figures = parse_figures()
    check_figures(figures)
    stats = check_references()
    check_markers(figures)

    print("\n" + "=" * 66)
    print("Resumen del catálogo")
    print(f"    Lecciones      {len(stats['lessons'])}")
    print(f"    Experimentos   {len(stats['experiments'])}")
    print(f"    Ejercicios     {len(stats['exercises'])}")
    print(f"    Casos          {len(stats['cases'])}")
    print(f"    Confusiones    {len(stats['catalog'])}")
    print(f"    Cifras         {len(figures)}")

    if warnings:
        print(f"\nAvisos ({len(warnings)}):")
        for w in warnings:
            print(f"    · {w}")
    if errors:
        print(f"\nERRORES ({len(errors)}):")
        for e in errors:
            print(f"    ✗ {e}")
        return 1
    print("\n✓ Contenido verificado sin errores")
    return 0


if __name__ == "__main__":
    sys.exit(main())
