from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parents[1]
path = root / "Assets/Download Source/Personnage/Personnage_vue_dessous_AK47_64x64.png"
sheet = Image.open(path).convert("RGBA")

frame = sheet.crop((0, 0, 64, 64)).resize((512, 512), Image.Resampling.NEAREST)
white = Image.new("RGBA", frame.size, (255,255,255,255))
white.alpha_composite(frame)
white.convert("RGB").save(root / "_AssetBackups/Personnage_AK47_final_frame0_white_8x.png")

row = Image.new("RGBA", (768, 64), (255,255,255,255))
row.alpha_composite(sheet)
row.resize((1536,128), Image.Resampling.NEAREST).convert("RGB").save(
    root / "_AssetBackups/Personnage_AK47_final_sheet_white_2x.png"
)
