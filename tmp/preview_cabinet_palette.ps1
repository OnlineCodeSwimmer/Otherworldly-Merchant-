Add-Type -AssemblyName System.Drawing
$sourcePath = Join-Path (Get-Location) 'Assets\AIGC Source\Building\Object\storage_cabinet_topdown_512x512.png'
$sourceBitmap = [System.Drawing.Bitmap]::new($sourcePath)
$previewBitmap = [System.Drawing.Bitmap]::new(512,512,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$previewGraphics = [System.Drawing.Graphics]::FromImage($previewBitmap)
$previewGraphics.Clear([System.Drawing.Color]::Transparent)
$previewGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$previewGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$previewGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$previewGraphics.DrawImage($sourceBitmap,[System.Drawing.Rectangle]::new(72,104,368,304),[System.Drawing.Rectangle]::new(210,219,92,76),[System.Drawing.GraphicsUnit]::Pixel)
$previewPath = Join-Path (Get-Location) 'tmp\imagegen\intact_cabinet_palette_reference_nn4.png'
if (Test-Path -LiteralPath $previewPath) { throw 'Preview already exists.' }
$previewBitmap.Save($previewPath,[System.Drawing.Imaging.ImageFormat]::Png)
$previewGraphics.Dispose(); $previewBitmap.Dispose(); $sourceBitmap.Dispose()
Write-Output $previewPath
