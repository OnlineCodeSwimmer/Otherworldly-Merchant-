# UZI character sprite

Created using built-in image_gen and an exact pixel-grid compositing pass.

- Asset: `Assets/Download Source/Personnage/Personnage_vue_dessous_UZI.png`
- 1152 x 96 transparent PNG; 12 frames, each 96 x 96.
- PPU 64, Point filter, no mipmaps, no compression. Original reference is 48 x 48 per frame at PPU 32; world-space size is unchanged.
- Character colors, silhouette, skin, and walking poses are nearest-neighbour copies of the user's revolver sequence. Only the gun region is changed.
- New UZI gun uses a 14 x 30 pixel template derived from the generated reference, quantized to six dark blue-grey colors. It is the same size and position in every frame, with original hand skin composited in front of the grip.
- A rendered checkerboard and body changes in the raw image_gen result were excluded. The delivered PNG has real alpha transparency.
- Original revolver, existing player animation clips, and animator controllers were not modified.

## Prompt

Use case: precise-object-edit. Input 1 is the EDIT TARGET: the existing pixel-art overhead character. Input 2 is the UZI weapon STYLE AND IDENTITY reference taken from the same game's gun icons. Replace the silver revolver held at the upper right with this UZI compact submachine gun, held in the SAME right hand, muzzle pointed straight toward the top of the image. Preserve the character's exact red oval hair, white shirt, tan right hand, shoulder silhouette, stance, placement, camera overhead angle and pixel-block look. Keep full square canvas, no crop, no recentering, no enlarging character. The original character is a 48x48 sprite enlarged to 768x768. The new UZI may use half-size pixels: compose on a 96x96 logical grid, while all character pixels remain on original 48x48 grid. Make gun visually substantial, about 14-16 pixels wide by 28-30 pixels long on this 96 grid, located entirely x=63..79 and y=1..31. Preserve comfortable transparent margin. Gun identity: charcoal black outline, muted blue-gray steel, chunky rectangular stamped receiver noticeably wider than pistol, short narrow barrel extending at the top, little sights and cocking knob, a compact folded metal stock alongside rear receiver, lower grip nestled in tan hand. Follow reference UZI industrial block shape and colors, adapted to an overhead in-game view, not the reference side view rotated. It must read as a UZI, not a long rifle or slim pistol. Fingers visibly hold the lower grip; muzzle clear of hand. Restrained 5-7 flat dark blue-grey colors with one thin muted steel highlight, hard crisp square pixels, no gloss gradients, no antialias, no soft shadows. Change only weapon and at most tiny finger contact pixels; keep all hair, white shirt, other hand, legs and body unchanged. Actual transparent background, never draw a checkerboard; if actual transparency unsupported use a uniform flat pure magenta background. No scenery, no words, no grid, no UI, no cast shadow. Deliver one single full-body top-down sprite, not a sheet.

