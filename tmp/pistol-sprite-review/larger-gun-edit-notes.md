# Larger pistol sprite edit

Mode: built-in image_gen, followed by cropped nearest-neighbour pixel-grid integration.

Final asset: `Assets/Download Source/Personnage/Personnage_vue_dessous_pistolet.png`

Original sheet remains 576 x 48, 12 frames at 48 x 48. Gun silhouette enlarged from 2 x 10 to a maximum 4 x 12 pixels. Generated slide and grip alone were extracted and quantized to four grey colors, then placed identically in all 12 original frames. Skin pixels and all pixels outside the gun region were preserved. Unity metadata was preserved. Copy of the pre-edit asset: `before-larger-gun.png` in this directory.

## Generation prompt

Use case: precise-object-edit. Edit target: supplied transparent top-down 48x48 logical pixel character, displayed enlarged to 768x768 (16 output pixels per logical pixel). Change ONLY the very thin upright pistol held at upper right. Make this pistol substantially more readable at small game scale, approximately FOUR logical pixels wide and TWELVE logical pixels long instead of current 2x10. Exact logical coordinates, origin upper left: upper slide spans x=34..37, y=3..11; narrower lower grip spans x=35..36,y=12..14 and stays nested in the unchanged skin-tone hand. Gun points straight UP, seen strictly from overhead, do not rotate to side view. Shape should be compact, thick pistol slide with very dark charcoal perimeter, muted medium steel-gray face, a restrained light-gray one-pixel highlight. A dark muzzle cap at y3 and a small dark notch on slide provide readable gun identity. Keep hard square logical pixels, at most four gun colors, no gradient, no antialias, no glow. Keep original character red hair, white shirt, skin, silhouette, pose, exact placement, scale, transparent background, canvas composition identical. No cast shadow, no new body parts, no labels, no text. Final must be same full square canvas framing so gun pixels map back to the 48x48 grid. Preserve actual alpha transparency.

## Integration notes

Generated image includes a rendered checkerboard and altered body pixels. These were excluded: only slide and grip pixels were used. The original asset supplied all body and background pixels. Preview is a nearest-neighbour comparison at 8x and 2x, not a capture of the running Unity game.
