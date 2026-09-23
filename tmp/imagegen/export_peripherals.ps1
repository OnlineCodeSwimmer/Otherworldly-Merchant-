$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$generatedFolder = 'C:\Users\望兴腾\.codex\generated_images\019f896a-5eb7-7d33-9f82-498fb98a05c0'
$destinationFolder = Join-Path (Get-Location) 'Assets\AIGC Source\Inventory Item'
$items = @(
    @{Name='mouse_common'; File='exec-dfbee49d-6f13-4817-ac70-c58ffe1ef9bc.png'},
    @{Name='keyboard_common'; File='exec-24124033-7a06-4541-9f82-cba44f941610.png'}
)
foreach ($item in $items) {
    $sourcePath = Join-Path $generatedFolder $item.File
    $fullPath = Join-Path $destinationFolder ($item.Name+'_source.png')
    $iconPath = Join-Path $destinationFolder ($item.Name+'_64x64.png')
    if ((Test-Path -LiteralPath $fullPath) -or (Test-Path -LiteralPath $iconPath)) { throw 'Output already exists.' }
    $src = [System.Drawing.Bitmap]::FromFile($sourcePath)
    if ($src.GetPixel(0,0).A -ne 0) { $src.Dispose(); throw 'Source corner is not transparent.' }
    Copy-Item -LiteralPath $sourcePath -Destination $fullPath
    $dst = [System.Drawing.Bitmap]::new(64,64,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($dst)
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $scale = 64.0 / [Math]::Max($src.Width,$src.Height)
    $w = [int][Math]::Round($src.Width*$scale)
    $h = [int][Math]::Round($src.Height*$scale)
    $g.DrawImage($src,[System.Drawing.Rectangle]::new([int]((64-$w)/2),[int]((64-$h)/2),$w,$h),[System.Drawing.Rectangle]::new(0,0,$src.Width,$src.Height),[System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    $dst.Save($iconPath,[System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output "$($item.Name): source $($src.Width)x$($src.Height), icon 64x64 RGBA, corner alpha=$($dst.GetPixel(0,0).A)"
    $src.Dispose()
    $dst.Dispose()
}
