Add-Type -AssemblyName System.Drawing
$bagSource = [System.Drawing.Bitmap]::new('C:\Users\望兴腾\.codex\generated_images\01a0ad86-844a-7e50-9b5e-4843c923a4c1\exec-d03bdee9-6021-496d-b353-6a70607092a4.png')
$left = $bagSource.Width; $top = $bagSource.Height; $right = -1; $bottom = -1
for ($y = 0; $y -lt $bagSource.Height; $y++) {
    for ($x = 0; $x -lt $bagSource.Width; $x++) {
        $color = $bagSource.GetPixel($x, $y)
        if ($color.A -ge 128) {
            $bagSource.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $color.R, $color.G, $color.B))
            $left = [Math]::Min($left, $x); $top = [Math]::Min($top, $y)
            $right = [Math]::Max($right, $x); $bottom = [Math]::Max($bottom, $y)
        } else {
            $bagSource.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
        }
    }
}
if ($right -lt 0) { throw 'No opaque bag pixels found.' }
$bagBounds = [System.Drawing.Rectangle]::new($left, $top, $right - $left + 1, $bottom - $top + 1)
$bagOutput = [System.Drawing.Bitmap]::new(48, 32, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$bagGraphics = [System.Drawing.Graphics]::FromImage($bagOutput)
$bagGraphics.Clear([System.Drawing.Color]::Transparent)
$bagGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$bagGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$bagGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$scale = [Math]::Min(44.0 / $bagBounds.Width, 24.0 / $bagBounds.Height)
$width = [int][Math]::Round($bagBounds.Width * $scale)
$height = [int][Math]::Round($bagBounds.Height * $scale)
$bagDestination = [System.Drawing.Rectangle]::new([int][Math]::Floor((48 - $width) / 2), [int][Math]::Floor((32 - $height) / 2), $width, $height)
$bagGraphics.DrawImage($bagSource, $bagDestination, $bagBounds, [System.Drawing.GraphicsUnit]::Pixel)
$bagTarget = Join-Path (Get-Location) 'Assets\AIGC Source\Building\Object\clinic_blue_fabric_cylindrical_bag_short_topdown_48x32.png'
if (Test-Path -LiteralPath $bagTarget) { throw "Refusing to overwrite: $bagTarget" }
$bagOutput.Save($bagTarget, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved: $bagTarget; canvas=48x32; object=$($width)x$($height); cornerAlpha=$($bagOutput.GetPixel(0,0).A)"
$bagGraphics.Dispose(); $bagOutput.Dispose(); $bagSource.Dispose()
