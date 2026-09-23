Add-Type -AssemblyName System.Drawing
$sourceBitmap = [System.Drawing.Bitmap]::new('C:\Users\望兴腾\.codex\generated_images\01a0ae4a-d442-7940-b14a-26c7fe151872\exec-2aa06c30-678b-4596-b42e-f446d64927c5.png')
$left = $sourceBitmap.Width; $top = $sourceBitmap.Height; $right = -1; $bottom = -1
for ($y = 0; $y -lt $sourceBitmap.Height; $y++) {
    for ($x = 0; $x -lt $sourceBitmap.Width; $x++) {
        $pixel = $sourceBitmap.GetPixel($x, $y)
        if ($pixel.A -ge 128) {
            $sourceBitmap.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $pixel.R, $pixel.G, $pixel.B))
            $left = [Math]::Min($left, $x); $top = [Math]::Min($top, $y)
            $right = [Math]::Max($right, $x); $bottom = [Math]::Max($bottom, $y)
        } else { $sourceBitmap.SetPixel($x, $y, [System.Drawing.Color]::Transparent) }
    }
}
if ($right -lt 0) { throw 'No cabinet pixels found.' }
$bounds = [System.Drawing.Rectangle]::new($left, $top, $right - $left + 1, $bottom - $top + 1)
$scale = [Math]::Min(112.0 / $bounds.Width, 112.0 / $bounds.Height)
$width = [int][Math]::Round($bounds.Width * $scale)
$height = [int][Math]::Round($bounds.Height * $scale)
$destination = [System.Drawing.Rectangle]::new([int][Math]::Floor((128 - $width) / 2), [int][Math]::Floor((128 - $height) / 2), $width, $height)
$logicalBitmap = [System.Drawing.Bitmap]::new(128, 128, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$logicalGraphics = [System.Drawing.Graphics]::FromImage($logicalBitmap)
$logicalGraphics.Clear([System.Drawing.Color]::Transparent)
$logicalGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$logicalGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$logicalGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$logicalGraphics.DrawImage($sourceBitmap, $destination, $bounds, [System.Drawing.GraphicsUnit]::Pixel)
$outputBitmap = [System.Drawing.Bitmap]::new(512, 512, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$outputGraphics = [System.Drawing.Graphics]::FromImage($outputBitmap)
$outputGraphics.Clear([System.Drawing.Color]::Transparent)
$outputGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$outputGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$outputGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$outputGraphics.DrawImage($logicalBitmap, [System.Drawing.Rectangle]::new(0, 0, 512, 512), [System.Drawing.Rectangle]::new(0, 0, 128, 128), [System.Drawing.GraphicsUnit]::Pixel)
$target = Join-Path (Get-Location) 'Assets\AIGC Source\Building\Object\Front Image\storage_cabinet_single_door_front_512x512.png'
if (Test-Path -LiteralPath $target) { throw "Refusing to overwrite: $target" }
$outputBitmap.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved: $target; canvas=512x512; logicalGrid=128x128; object=$($width*4)x$($height*4); cornerAlpha=$($outputBitmap.GetPixel(0,0).A)"
$logicalGraphics.Dispose(); $outputGraphics.Dispose(); $outputBitmap.Dispose(); $logicalBitmap.Dispose(); $sourceBitmap.Dispose()
