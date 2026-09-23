$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$gpuSource = 'C:\Users\望兴腾\.codex\generated_images\019f896a-5eb7-7d33-9f82-498fb98a05c0\exec-51385efa-921e-4c5b-9b2f-14148cba4b7a.png'
$gpuFolder = Join-Path (Get-Location) 'Assets\AIGC Source\Icon'
$gpuFull = Join-Path $gpuFolder 'graphics_card_common_source.png'
$gpuSmall = Join-Path $gpuFolder 'graphics_card_common_64x64.png'
if ((Test-Path -LiteralPath $gpuFull) -or (Test-Path -LiteralPath $gpuSmall)) { throw 'Destination exists; preserve previous assets.' }
Copy-Item -LiteralPath $gpuSource -Destination $gpuFull
$src = [System.Drawing.Bitmap]::FromFile($gpuSource)
$dst = [System.Drawing.Bitmap]::new(64,64,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($dst)
$g.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.DrawImage($src,[System.Drawing.Rectangle]::new(0,0,64,64),[System.Drawing.Rectangle]::new(0,0,$src.Width,$src.Height),[System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
$dst.Save($gpuSmall,[System.Drawing.Imaging.ImageFormat]::Png)
$transparent = 0
$opaque = 0
for ($y=0; $y -lt 64; $y++) { for ($x=0; $x -lt 64; $x++) { if ($dst.GetPixel($x,$y).A -eq 0) { $transparent++ } else { $opaque++ } } }
Write-Output "Source: $($src.Width)x$($src.Height), $($src.PixelFormat), corner alpha $($src.GetPixel(0,0).A)"
Write-Output "Icon: 64x64, transparent pixels $transparent, nontransparent pixels $opaque"
Write-Output $gpuSmall
$src.Dispose()
$dst.Dispose()
