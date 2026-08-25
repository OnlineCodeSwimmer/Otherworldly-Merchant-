from pathlib import Path
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "Assets" / "AIGC Source" / "Building" / "Object" / "clinic_staircase_strict_topdown_64x128.png"
PREVIEW = ROOT / "_AssetBackups" / "clinic_staircase_strict_topdown_64x128_preview_4x.png"


def rect(img: Image.Image, box: tuple[int, int, int, int], color: tuple[int, int, int, int]) -> None:
    px = img.load()
    x0, y0, x1, y1 = box
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            px[x, y] = color


def main() -> None:
    canvas = Image.new("RGBA", (64, 128), (0, 0, 0, 0))

    outline = (52, 64, 82, 255)
    border_mid = (103, 116, 135, 255)
    separator = (122, 135, 151, 255)
    tread_colors = [
        (238, 240, 243, 255),
        (232, 235, 239, 255),
        (225, 229, 234, 255),
        (217, 222, 228, 255),
        (207, 213, 221, 255),
        (198, 205, 214, 255),
        (188, 196, 206, 255),
        (177, 186, 198, 255),
        (166, 176, 189, 255),
    ]

    # Exact orthographic rectangle. The frame width does not change from top
    # to bottom, so the sprite contains no perspective or trapezoid effect.
    rect(canvas, (3, 8, 60, 119), outline)
    rect(canvas, (5, 10, 58, 117), border_mid)

    # Nine equal 12-pixel tread footprints. Horizontal separator lines denote
    # tread boundaries only; no vertical riser or side face is drawn.
    for index, color in enumerate(tread_colors):
        y0 = 10 + index * 12
        rect(canvas, (7, y0, 56, y0 + 1), separator)
        rect(canvas, (7, y0 + 2, 56, y0 + 11), color)

    # Flat side strips viewed from above, kept thin and perfectly parallel.
    rect(canvas, (5, 10, 6, 117), (78, 92, 111, 255))
    rect(canvas, (57, 10, 58, 117), (78, 92, 111, 255))

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(OUTPUT, optimize=False)

    checker = Image.new("RGBA", (64, 128), (190, 194, 199, 255))
    for y in range(0, 128, 8):
        for x in range(0, 64, 8):
            if (x // 8 + y // 8) % 2:
                rect(checker, (x, y, min(x + 7, 63), min(y + 7, 127)), (213, 216, 220, 255))
    checker.alpha_composite(canvas)
    checker.resize((256, 512), Image.Resampling.NEAREST).save(PREVIEW, optimize=False)

    alpha = canvas.getchannel("A")
    values = list(alpha.getdata())
    opaque = sum(value == 255 for value in values)
    partial = sum(value not in (0, 255) for value in values)
    corners = [canvas.getpixel(point)[3] for point in ((0, 0), (63, 0), (0, 127), (63, 127))]
    print(f"output={OUTPUT}")
    print(f"size={canvas.size} opaque={opaque} partial_alpha={partial} corner_alpha={corners}")


if __name__ == "__main__":
    main()
