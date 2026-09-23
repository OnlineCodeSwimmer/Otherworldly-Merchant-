$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$sourcePath = 'C:\Users\望兴腾\.codex\generated_images\019f896a-5eb7-7d33-9f82-498fb98a05c0\exec-0cc1b0cb-55c2-4cef-9757-1842e53a4a26.png'
$outputFolder = Join-Path (Get-Location) 'Assets\AIGC Source\Inventory Item'
$sourceOutput = Join-Path $outputFolder 'usb_flash_drive_common_v2_source.png'
$icon128Output = Join-Path $outputFolder 'usb_flash_drive_common_v2_128x128.png'
$icon64Output = Join-Path $outputFolder 'usb_flash_drive_common_v2_64x64.png'

foreach ($path in @($sourceOutput,$icon128Output,$icon64Output)) {
    if (Test-Path -LiteralPath $path) { throw "Output already exists: $path" }
}

$input = [System.Drawing.Bitmap]::FromFile($sourcePath)
$clean = [System.Drawing.Bitmap]::new($input.Width,$input.Height,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$minX = $input.Width
$minY = $input.Height
$maxX = -1
$maxY = -1
$transparentCount = 0

for ($y=0; $y -lt $input.Height; $y++) {
    for ($x=0; $x -lt $input.Width; $x++) {
        $color = $input.GetPixel($x,$y)
        $isMagenta = $color.R -gt ($color.G + 35) -and $color.B -gt ($color.G + 35)
        if ($isMagenta) {
            $clean.SetPixel($x,$y,[System.Drawing.Color]::Transparent)
            $transparentCount++
        } else {
            $opaque = [System.Drawing.Color]::FromArgb(255,$color.R,$color.G,$color.B)
            $clean.SetPixel($x,$y,$opaque)
            if ($x -lt $minX) { $minX=$x }
            if ($x -gt $maxX) { $maxX=$x }
            if ($y -lt $minY) { $minY=$y }
            if ($y -gt $maxY) { $maxY=$y }
        }
    }
}
$input.Dispose()
if ($maxX -lt 0) { throw 'No object pixels found.' }
$clean.Save($sourceOutput,[System.Drawing.Imaging.ImageFormat]::Png)

function Export-Icon([int]$size,[string]$path) {
    $padding = if ($size -eq 128) { 8 } else { 4 }
    $available = $size - 2*$padding
    $cropWidth = $maxX-$minX+1
    $cropHeight = $maxY-$minY+1
    $scale = [Math]::Min($available/$cropWidth,$available/$cropHeight)
    $drawWidth = [Math]::Max(1,[int][Math]::Round($cropWidth*$scale))
    $drawHeight = [Math]::Max(1,[int][Math]::Round($cropHeight*$scale))
    $drawX = [int][Math]::Floor(($size-$drawWidth)/2)
    $drawY = [int][Math]::Floor(($size-$drawHeight)/2)
    $icon = [System.Drawing.Bitmap]::new($size,$size,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($icon)
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $graphics.DrawImage($clean,[System.Drawing.Rectangle]::new($drawX,$drawY,$drawWidth,$drawHeight),[System.Drawing.Rectangle]::new($minX,$minY,$cropWidth,$cropHeight),[System.Drawing.GraphicsUnit]::Pixel)
    $graphics.Dispose()
    $icon.Save($path,[System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output "${size}x${size}: object ${drawWidth}x${drawHeight}, corner alpha=$($icon.GetPixel(0,0).A)"
    $icon.Dispose()
}

Export-Icon 128 $icon128Output
Export-Icon 64 $icon64Output
Write-Output "Source crop: $minX,$minY to $maxX,$maxY; transparent pixels=$transparentCount"
$clean.Dispose()
