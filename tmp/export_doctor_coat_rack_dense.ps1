Add-Type -AssemblyName System.Drawing
$stairSource = [System.Drawing.Bitmap]::new('C:\Users\望兴腾\.codex\generated_images\01a0ad86-844a-7e50-9b5e-4843c923a4c1\exec-17512e12-deec-4559-b3dc-3bb0863d490a.png')
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
$stairOutput = [System.Drawing.Bitmap]::new(64, 128, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($stairOutput)
$graphics.Clear([System.Drawing.Color]::Transparent)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$scale = [Math]::Min(56.0 / $bounds.Width, 120.0 / $bounds.Height)
$width = [int][Math]::Round($bounds.Width * $scale)
$height = [int][Math]::Round($bounds.Height * $scale)
$destination = [System.Drawing.Rectangle]::new([int][Math]::Floor((64 - $width) / 2), [int][Math]::Floor((128 - $height) / 2), $width, $height)
$graphics.DrawImage($stairSource, $destination, $bounds, [System.Drawing.GraphicsUnit]::Pixel)
$target = Join-Path (Get-Location) 'Assets\AIGC Source\Building\Object\clinic_doctor_coat_rack_dense_vertical_topdown_64x128.png'
if (Test-Path -LiteralPath $target) { throw "Refusing to overwrite: $target" }
$stairOutput.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved: $target; canvas=64x128; object=$($width)x$($height); cornerAlpha=$($stairOutput.GetPixel(0,0).A)"
$graphics.Dispose(); $stairOutput.Dispose(); $stairSource.Dispose()
