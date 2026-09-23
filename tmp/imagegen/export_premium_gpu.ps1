$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$source = 'C:\Users\望兴腾\.codex\generated_images\019f896a-5eb7-7d33-9f82-498fb98a05c0\exec-1ec4ebad-2930-4c2c-a376-4e82d6767743.png'
$folder = Join-Path (Get-Location) 'Assets\AIGC Source\Inventory Item'
$full = Join-Path $folder 'graphics_card_premium_source.png'
$small = Join-Path $folder 'graphics_card_premium_64x64.png'
if ((Test-Path -LiteralPath $full) -or (Test-Path -LiteralPath $small)) { throw 'Destination exists.' }
Copy-Item -LiteralPath $source -Destination $full
$src = [System.Drawing.Bitmap]::FromFile($source)
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
$dst.Save($small,[System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Exported 64x64 RGBA, corner alpha=$($dst.GetPixel(0,0).A)"
Write-Output $small
$src.Dispose()
$dst.Dispose()
