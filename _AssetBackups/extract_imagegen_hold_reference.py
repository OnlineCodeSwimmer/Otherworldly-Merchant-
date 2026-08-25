from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = Image.open(ROOT / "_AssetBackups/imagegen_correct_ak_hold_reference.png").convert("RGB")
OUT = ROOT / "_AssetBackups"

SW = SRC.width / 12
previews = []
for i in range(12):
    x0, x1 = round(i * SW), round((i + 1) * SW)
    crop = SRC.crop((x0, 0, x1, SRC.height))
    # Isolate the generated subject from its almost-black background.
    rgba = Image.new("RGBA", crop.size, (0, 0, 0, 0))
    for y in range(crop.height):
        for x in range(crop.width):
            r, g, b = crop.getpixel((x, y))
            if max(r, g, b) > 18:
                rgba.putpixel((x, y), (r, g, b, 255))
    bbox = rgba.getbbox()
    subject = rgba.crop(bbox)
    # Generated subject is ~143x221. 25% yields ~36x55, close to the source
    # player's 36x33 body while leaving enough height for a real rifle.
    w, h = round(subject.width * .25), round(subject.height * .25)
    subject = subject.resize((w, h), Image.Resampling.NEAREST)
    # Quantize to a limited hard-edged pixel palette.
    rgb = Image.new("RGB", subject.size, "black")
    rgb.paste(subject.convert("RGB"), mask=subject.getchannel("A"))
    pal = rgb.quantize(colors=12, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert("RGBA")
    for y in range(pal.height):
        for x in range(pal.width):
            if subject.getpixel((x, y))[3] == 0:
                pal.putpixel((x, y), (0, 0, 0, 0))
    cell = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    cell.alpha_composite(pal, ((64-w)//2, max(0, 64-h)))
    previews.append(cell)

sheet = Image.new("RGBA", (64*12, 64), (0, 0, 0, 0))
for i, cell in enumerate(previews):
    sheet.alpha_composite(cell, (i*64, 0))
sheet.save(OUT / "imagegen_correct_hold_scaled_reference.png")

zoom = Image.new("RGBA", (64*8*3, 64*8), (255,255,255,255))
for i in range(3):
    z = previews[i].resize((64*8,64*8), Image.Resampling.NEAREST)
    zoom.alpha_composite(z, (i*64*8,0))
zoom.convert("RGB").save(OUT / "imagegen_correct_hold_scaled_reference_zoom.png")
print("extracted scaled reference")
