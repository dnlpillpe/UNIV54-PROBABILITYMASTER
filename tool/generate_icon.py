#!/usr/bin/env python3
"""Genera el icono de Probability Master.

Reproduce en Pillow exactamente el mismo dibujo que `BrandPainter` hace con
`CustomPainter` en `lib/presentation/painters/brand_painter.dart`: un dado
blanco sobre una curva de convergencia turquesa, en un fondo índigo.

Que el icono y el logotipo de la app salgan del mismo dibujo no es un detalle
estético: evita que la marca de la tienda y la de la pantalla de inicio se
separen con el tiempo.

Uso:
    python3 tool/generate_icon.py
Salida:
    assets/icon/app_icon.png             (1024x1024, con fondo)
    assets/icon/app_icon_foreground.png  (1024x1024, transparente, para
                                          el icono adaptativo de Android)
"""

from __future__ import annotations

import math
import os

from PIL import Image, ImageDraw

SIZE = 1024
SS = 4  # supermuestreo para bordes suaves

INDIGO_TOP = (91, 75, 234)
INDIGO_DEEP = (45, 36, 150)
TEAL = (18, 165, 148)
AMBER = (233, 161, 59)
WHITE = (255, 255, 255)
PIP = (45, 36, 150)


def rounded_rect(draw, box, radius, fill):
    draw.rounded_rectangle(box, radius=radius, fill=fill)


def vertical_gradient(size, top, bottom):
    """Degradado diagonal aproximado por interpolación vertical + horizontal."""
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        for x in range(0, size, 8):
            t = (x / size * 0.45 + y / size * 0.55)
            r = int(top[0] + (bottom[0] - top[0]) * t)
            g = int(top[1] + (bottom[1] - top[1]) * t)
            b = int(top[2] + (bottom[2] - top[2]) * t)
            for dx in range(8):
                if x + dx < size:
                    px[x + dx, y] = (r, g, b)
    return img


def convergence_points(width, height, amplitude=0.46, waves=7, steps=160):
    """Misma curva que `convergencePath` en brand_painter.dart."""
    pts = []
    mid = height * 0.5
    for i in range(steps + 1):
        t = i / steps
        decay = math.exp(-3.1 * t)
        y = mid - math.sin(t * waves * math.pi) * height * amplitude * decay
        pts.append((t * width, y))
    return pts


def draw_die(layer_size, die_size, pip_value=5):
    """Dibuja un dado blanco en una capa propia, para poder rotarla."""
    die = Image.new("RGBA", (layer_size, layer_size), (0, 0, 0, 0))
    d = ImageDraw.Draw(die)
    off = (layer_size - die_size) / 2
    box = (off, off, off + die_size, off + die_size)
    rounded_rect(d, box, radius=int(die_size * 0.22), fill=WHITE + (255,))

    r = die_size * 0.085
    cx = off + die_size / 2
    cy = off + die_size / 2
    dx = die_size * 0.24
    dy = die_size * 0.24

    def dot(x, y):
        d.ellipse((x - r, y - r, x + r, y + r), fill=PIP + (255,))

    positions = {
        1: [(cx, cy)],
        2: [(cx - dx, cy - dy), (cx + dx, cy + dy)],
        3: [(cx - dx, cy - dy), (cx, cy), (cx + dx, cy + dy)],
        4: [(cx - dx, cy - dy), (cx + dx, cy - dy),
            (cx - dx, cy + dy), (cx + dx, cy + dy)],
        5: [(cx - dx, cy - dy), (cx + dx, cy - dy), (cx, cy),
            (cx - dx, cy + dy), (cx + dx, cy + dy)],
        6: [(cx - dx, cy - dy), (cx + dx, cy - dy), (cx - dx, cy),
            (cx + dx, cy), (cx - dx, cy + dy), (cx + dx, cy + dy)],
    }
    for (x, y) in positions[pip_value]:
        dot(x, y)
    return die


def build(with_background: bool) -> Image.Image:
    size = SIZE * SS
    if with_background:
        base = vertical_gradient(size, INDIGO_TOP, INDIGO_DEEP).convert("RGBA")
        mask = Image.new("L", (size, size), 0)
        ImageDraw.Draw(mask).rounded_rectangle(
            (0, 0, size - 1, size - 1), radius=int(size * 0.235), fill=255
        )
        canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        canvas.paste(base, (0, 0), mask)
    else:
        canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    draw = ImageDraw.Draw(canvas)

    # --- Curva de convergencia -------------------------------------
    curve_left = size * 0.06
    curve_top = size * 0.50
    curve_w = size * 0.88
    curve_h = size * 0.36
    pts = [
        (curve_left + x, curve_top + y)
        for (x, y) in convergence_points(curve_w, curve_h)
    ]

    # Línea teórica a la que converge.
    mid_y = curve_top + curve_h * 0.5
    draw.line(
        [(curve_left, mid_y), (curve_left + curve_w, mid_y)],
        fill=(255, 255, 255, 115),
        width=int(size * 0.016),
    )
    draw.line(pts, fill=TEAL + (255,), width=int(size * 0.048), joint="curve")
    # Extremos redondeados.
    cap = size * 0.024
    for (x, y) in (pts[0], pts[-1]):
        draw.ellipse((x - cap, y - cap, x + cap, y + cap), fill=TEAL + (255,))
    # Punto ámbar al final.
    ax, ay = curve_left + curve_w, mid_y
    ar = size * 0.042
    draw.ellipse((ax - ar, ay - ar, ax + ar, ay + ar), fill=AMBER + (255,))

    # --- Dado -------------------------------------------------------
    die_size = int(size * 0.46)
    layer = int(die_size * 1.7)
    die = draw_die(layer, die_size, pip_value=5)
    die = die.rotate(19.8, resample=Image.BICUBIC, expand=False)
    die_cx = size * 0.5 - size * 0.02
    die_cy = size * 0.345
    canvas.alpha_composite(
        die, (int(die_cx - layer / 2), int(die_cy - layer / 2))
    )

    return canvas.resize((SIZE, SIZE), Image.LANCZOS)


def main():
    here = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    out_dir = os.path.join(here, "assets", "icon")
    os.makedirs(out_dir, exist_ok=True)

    icon = build(with_background=True)
    icon.convert("RGB").save(os.path.join(out_dir, "app_icon.png"))

    # El primer plano adaptativo se dibuja al 62 % y centrado: Android recorta
    # los bordes del icono adaptativo con formas distintas según el lanzador.
    fg_full = build(with_background=False)
    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    scaled = fg_full.resize((int(SIZE * 0.62), int(SIZE * 0.62)), Image.LANCZOS)
    fg.alpha_composite(
        scaled,
        ((SIZE - scaled.width) // 2, (SIZE - scaled.height) // 2),
    )
    fg.save(os.path.join(out_dir, "app_icon_foreground.png"))

    print("Icono generado en assets/icon/")
    print("  app_icon.png            1024x1024")
    print("  app_icon_foreground.png 1024x1024 (transparente)")


if __name__ == "__main__":
    main()
