# Empty medicine shelf

- Mode: built-in image_gen, precise-object-edit
- Source: Assets/AIGC Source/Building/Object/clinic_medicine_gondola_shelf_topdown_512x512.png
- Output: Assets/AIGC Source/Building/Object/clinic_medicine_gondola_shelf_empty_topdown.png
- Generated size: 1254 x 1254, RGBA with transparent background. Original source retained.
- Unity: Sprite Single, Point filtering, no mipmaps, no compression, 244.921875 pixels per unit to keep the original 5.12-unit square canvas size.
- Minor generative edge differences from the reference; not a pixel-identical inpaint. Very faint low-alpha fringe is present outside the main silhouette.

## Final prompt

Use case: precise-object-edit
Asset type: Unity 2D pixel-art sprite, EMPTY medicine shelf, transparent PNG.
Input image: the attached existing 512x512 top-down medicine shelf sprite is the EDIT TARGET, not just inspiration.
Primary request: Remove ALL medicine bottles, pill jars, cartons and boxes from the shelf surface. Inpaint only those object footprints and their small outlines/shadows with the same flat dark gray shelf deck. The result must be the SAME shelf, completely empty.
Preserve: exact orthographic top-down view, thin long horizontal silhouette, original shelf proportions and centered position, charcoal gray pixel-art deck, narrow back rim, the two square mounting posts with small holes at its back corners, and pale blue-white thin front lip. Preserve the original low-resolution pixel edges and minimal flat shading. Do not redraw or redesign the structure. No shelves in frontal perspective, no isometric view, no extra dividers, no added items.
Composition: keep the same square canvas, preferably 512 x 512 pixels; the shelf occupies approximately x=98..414 and y=219..294 on the 512px reference. Preserve this bounding box proportion and generous transparent margins. All pixels outside the shelf must be truly transparent (alpha=0), not opaque black or a drawn checkerboard. No ground plane, no labels, no text, no watermark.
