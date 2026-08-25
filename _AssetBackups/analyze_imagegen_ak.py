from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parents[1]
src = Image.open(root / "_AssetBackups/imagegen_correct_ak_hold_reference.png").convert("RGB")

cell_w = src.width / 12
for i in range(12):
    x0 = round(i * cell_w)
    x1 = round((i + 1) * cell_w)
    crop = src.crop((x0, 0, x1, src.height))
    pix = crop.load()
    xs, ys = [], []
    for y in range(crop.height):
        for x in range(crop.width):
            r, g, b = pix[x, y]
            if max(r, g, b) > 18:
                xs.append(x)
                ys.append(y)
    print(i, (min(xs), min(ys), max(xs)+1, max(ys)+1), "cell", crop.size)
