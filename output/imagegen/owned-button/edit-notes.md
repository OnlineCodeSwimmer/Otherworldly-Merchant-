# OWNED disabled button

Mode: built-in image_gen, followed by reduction to 160x48, grey-palette cleanup, and flattening of generated fill texture.

Final sprite: `Assets/AIGC Source/UI/Shop/win98_button_owned_disabled_160x48.png`. Blank background, no baked lettering. Pressed-in top/left shadows and bottom/right highlights, with a flat #D2D2D2 fill. New Sprite metadata uses PPU 100, Point filtering, no compression or mipmaps, and 3px slicing borders.

The labeled preview reuses the user's screenshot lettering, rendered in #848484 with a light offset to demonstrate a disabled label. That lettering is not part of the Unity background sprite. Existing components and interaction logic were not changed.

## Generation prompt

Use case: precise-object-edit. Asset: a Windows 98 style UI button sprite in its OWNED / disabled / permanently pressed-in state. Image 1 is the blank NORMAL button to edit. Image 2 shows its current OWNED label in the game, reference only. Produce the edited blank background WITHOUT any text, because Unity already renders the OWNED label separately. Keep the exact long rectangular shape, width:height=160:48 (10:3), square corners, same light neutral gray palette. Change the raised beveled border into a thin INSET sunken border: darker medium-gray top and left edges, slightly darker inner top-left hairline, lighter bottom and right edge. Body is uniform matte light gray about #D2D2D2, slightly darker and duller than original #E4E4E4. The whole button should look shallowly pressed down and inactive, not like a raised button or an input textbox. Subtle old desktop pixel UI, crisp straight one-to-two-pixel lines at final 160x48, restrained 4-5 gray shades, no thick black frame, no dark fill, no texture, no gradient, no glossy highlights, no drop shadow, no rounding. Fill entire canvas with the exact rectangular button asset, no surrounding canvas, no mockup, no scene, no captions, no label. Requested native sprite 160x48, may render at exactly 10x as 1600x480 so downsampling preserves structure. Do not generate any other assets.

