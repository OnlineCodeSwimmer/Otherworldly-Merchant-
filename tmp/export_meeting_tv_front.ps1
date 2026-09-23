Add-Type -AssemblyName System.Drawing
$tvSource = [System.Drawing.Bitmap]::new('C:\Users\望兴腾\.codex\generated_images\01a0ad86-844a-7e50-9b5e-4843c923a4c1\exec-c1cd38b7-83ed-4bce-88f4-268907688181.png')
$left = $tvSource.Width; $top = $tvSource.Height; $right = -1; $bottom = -1
for ($y = 0; $y -lt $tvSource.Height; $y++) {
    for ($x = 0; $x -lt $tvSource.Width; $x++) {
        $color = $tvSource.GetPixel($x, $y)
        if ($color.A -ge 128) {
            $tvSource.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $color.R, $color.G, $color.B))
            $left = [Math]::Min($left, $x); $top = [Math]::Min($top, $y)
            $right = [Math]::Max($right, $x); $bottom = [Math]::Max($bottom, $y)
        } else {
            $tvSource.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
        }
    }
}
if ($right -lt 0) { throw 'No opaque television pixels found.' }
$tvBounds = [System.Drawing.Rectangle]::new($left, $top, $right - $left + 1, $bottom - $top + 1)
$tvOutput = [System.Drawing.Bitmap]::new(128, 80, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$tvGraphics = [System.Drawing.Graphics]::FromImage($tvOutput)
$tvGraphics.Clear([System.Drawing.Color]::Transparent)
$tvGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$tvGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$tvGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$scale = [Math]::Min(124.0 / $tvBounds.Width, 74.0 / $tvBounds.Height)
$width = [int][Math]::Round($tvBounds.Width * $scale)
$height = [int][Math]::Round($tvBounds.Height * $scale)
$tvDestination = [System.Drawing.Rectangle]::new([int][Math]::Floor((128 - $width) / 2), [int][Math]::Floor((80 - $height) / 2), $width, $height)
$tvGraphics.DrawImage($tvSource, $tvDestination, $tvBounds, [System.Drawing.GraphicsUnit]::Pixel)
$tvTarget = Join-Path (Get-Location) 'Assets\AIGC Source\Building\Object\Meeting Room\meeting_tv_front_128x80.png'
if (Test-Path -LiteralPath $tvTarget) { throw "Refusing to overwrite: $tvTarget" }
$tvOutput.Save($tvTarget, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved: $tvTarget; canvas=128x80; object=$($width)x$($height); cornerAlpha=$($tvOutput.GetPixel(0,0).A)"
$tvGraphics.Dispose(); $tvOutput.Dispose(); $tvSource.Dispose()
