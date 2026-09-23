Add-Type -AssemblyName System.Drawing
$referenceBitmap = [System.Drawing.Bitmap]::new('C:\Users\望兴腾\.codex\generated_images\01a0ae4a-d442-7940-b14a-26c7fe151872\exec-9a0a95ba-b8ac-45a1-a8a1-2fd907ddb4c5.png')
$editedBitmap = [System.Drawing.Bitmap]::new('C:\Users\望兴腾\.codex\generated_images\01a0ae4a-d442-7940-b14a-26c7fe151872\exec-d365774c-dc8d-476b-9d3d-94b61ff95226.png')
if ($referenceBitmap.Width -ne $editedBitmap.Width -or $referenceBitmap.Height -ne $editedBitmap.Height) { throw 'Reference and edit canvas dimensions must match.' }
$left = $referenceBitmap.Width; $top = $referenceBitmap.Height; $right = -1; $bottom = -1
for ($y = 0; $y -lt $referenceBitmap.Height; $y++) {
    for ($x = 0; $x -lt $referenceBitmap.Width; $x++) {
        if ($referenceBitmap.GetPixel($x, $y).A -ge 128) {
            $left = [Math]::Min($left, $x); $top = [Math]::Min($top, $y)
            $right = [Math]::Max($right, $x); $bottom = [Math]::Max($bottom, $y)
        }
        $pixel = $editedBitmap.GetPixel($x, $y)
        if ($pixel.A -ge 128) { $editedBitmap.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $pixel.R, $pixel.G, $pixel.B)) }
        else { $editedBitmap.SetPixel($x, $y, [System.Drawing.Color]::Transparent) }
    }
}
if ($right -lt 0) { throw 'No reference sprite pixels found.' }
# Reuse the original crop and scale so removing the tray does not enlarge the body.
$bounds = [System.Drawing.Rectangle]::new($left, $top, $right - $left + 1, $bottom - $top + 1)
$scale = [Math]::Min(56.0 / $bounds.Width, 56.0 / $bounds.Height)
$width = [int][Math]::Round($bounds.Width * $scale)
$height = [int][Math]::Round($bounds.Height * $scale)
$destination = [System.Drawing.Rectangle]::new([int][Math]::Floor((64 - $width) / 2), [int][Math]::Floor((64 - $height) / 2), $width, $height)
$outputBitmap = [System.Drawing.Bitmap]::new(64, 64, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($outputBitmap)
$graphics.Clear([System.Drawing.Color]::Transparent)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$graphics.DrawImage($editedBitmap, $destination, $bounds, [System.Drawing.GraphicsUnit]::Pixel)
$target = Join-Path (Get-Location) 'Assets\AIGC Source\Building\Object\Office\office_coffee_machine_flush_topdown_64x64.png'
if (Test-Path -LiteralPath $target) { throw "Refusing to overwrite: $target" }
$outputBitmap.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved: $target; canvas=64x64; originalScaleRetained=true; cornerAlpha=$($outputBitmap.GetPixel(0,0).A)"
$graphics.Dispose(); $outputBitmap.Dispose(); $referenceBitmap.Dispose(); $editedBitmap.Dispose()
