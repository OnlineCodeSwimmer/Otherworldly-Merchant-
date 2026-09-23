Add-Type -AssemblyName System.Drawing
$stairSource = [System.Drawing.Bitmap]::new('C:\Users\望兴腾\.codex\generated_images\01a0ad86-844a-7e50-9b5e-4843c923a4c1\exec-d18e1d1b-6cc7-41b9-ac04-a8addb28dcde.png')
$left = $stairSource.Width; $top = $stairSource.Height; $right = -1; $bottom = -1
for ($y = 0; $y -lt $stairSource.Height; $y++) {
    for ($x = 0; $x -lt $stairSource.Width; $x++) {
        $color = $stairSource.GetPixel($x, $y)
        if ($color.A -ge 128) {
            $stairSource.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $color.R, $color.G, $color.B))
            $left = [Math]::Min($left, $x); $top = [Math]::Min($top, $y)
            $right = [Math]::Max($right, $x); $bottom = [Math]::Max($bottom, $y)
        } else { $stairSource.SetPixel($x, $y, [System.Drawing.Color]::Transparent) }
    }
}
if ($right -lt 0) { throw 'No opaque coat rack pixels found.' }
$bounds = [System.Drawing.Rectangle]::new($left, $top, $right - $left + 1, $bottom - $top + 1)
$stairOutput = [System.Drawing.Bitmap]::new(64, 96, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($stairOutput)
$graphics.Clear([System.Drawing.Color]::Transparent)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$scale = [Math]::Min(56.0 / $bounds.Width, 88.0 / $bounds.Height)
$width = [int][Math]::Round($bounds.Width * $scale)
$height = [int][Math]::Round($bounds.Height * $scale)
$destination = [System.Drawing.Rectangle]::new([int][Math]::Floor((64 - $width) / 2), [int][Math]::Floor((96 - $height) / 2), $width, $height)
$graphics.DrawImage($stairSource, $destination, $bounds, [System.Drawing.GraphicsUnit]::Pixel)
$target = 'C:\Users\望兴腾\.codex\visualizations\2026\09\17\01a0ad86-844a-7e50-9b5e-4843c923a4c1\clinic_coat_rack_real_hanging_64x96.png'
if (Test-Path -LiteralPath $target) { throw "Refusing to overwrite: $target" }
$stairOutput.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved: $target; canvas=64x96; object=$($width)x$($height); cornerAlpha=$($stairOutput.GetPixel(0,0).A)"
$rackPreview = [System.Drawing.Bitmap]::new(256, 384, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$rackPreviewGraphics = [System.Drawing.Graphics]::FromImage($rackPreview)
$rackPreviewGraphics.Clear([System.Drawing.Color]::Transparent)
$rackPreviewGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$rackPreviewGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$rackPreviewGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$rackPreviewGraphics.DrawImage($stairOutput, [System.Drawing.Rectangle]::new(0,0,256,384), [System.Drawing.Rectangle]::new(0,0,64,96), [System.Drawing.GraphicsUnit]::Pixel)
$rackPreview.Save('C:\Users\望兴腾\.codex\visualizations\2026\09\17\01a0ad86-844a-7e50-9b5e-4843c923a4c1\clinic_coat_rack_real_hanging_preview_4x.png', [System.Drawing.Imaging.ImageFormat]::Png)
$rackPreviewGraphics.Dispose(); $rackPreview.Dispose()
$graphics.Dispose(); $stairOutput.Dispose(); $stairSource.Dispose()
