from pathlib import Path
from PIL import Image, ImageDraw

root = Path(__file__).resolve().parents[1]
person = root / "Assets/Download Source/Personnage"
files = [person / "Personnage_vue_dessous_AK47.png"]
files += [person / f"Personnage_vue_dessous_AK47_v{i}.png" for i in range(2, 15)]
files += [person / "Personnage_vue_dessous_AK47_64x64.png"]

thumb_w, thumb_h = 320, 160
canvas = Image.new("RGB", (thumb_w * 3, thumb_h * 5), "white")
draw = ImageDraw.Draw(canvas)
for index, path in enumerate(files):
    if not path.exists():
        continue
    im = Image.open(path).convert("RGBA")
    cell_w = im.width // 12
    frame = im.crop((0, 0, cell_w, im.height))
    bbox = frame.getbbox()
    if bbox:
        frame = frame.crop(bbox)
    scale = min(12, max(1, min((thumb_w - 20) // max(1, frame.width), (thumb_h - 28) // max(1, frame.height))))
    frame = frame.resize((frame.width * scale, frame.height * scale), Image.Resampling.NEAREST)
    bg = Image.new("RGBA", frame.size, (255, 255, 255, 255))
    bg.alpha_composite(frame)
    x0 = (index % 3) * thumb_w
    y0 = (index // 3) * thumb_h
    canvas.paste(bg.convert("RGB"), (x0 + (thumb_w - frame.width) // 2, y0 + 20))
    draw.text((x0 + 6, y0 + 3), f"{path.stem}  {im.size}", fill="black")

out = root / "_AssetBackups/AK47_all_versions_contact.png"
canvas.save(out)
print(out)
