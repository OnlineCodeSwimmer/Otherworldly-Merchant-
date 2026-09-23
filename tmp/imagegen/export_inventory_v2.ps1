$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$genFolder = 'C:\Users\望兴腾\.codex\generated_images\019f896a-5eb7-7d33-9f82-498fb98a05c0'
$outFolder = Join-Path (Get-Location) 'Assets\AIGC Source\Inventory Item'
$previewPath = 'C:\Users\望兴腾\.codex\visualizations\2026\07\22\019f896a-5eb7-7d33-9f82-498fb98a05c0\inventory_v2_preview.png'
$items = @(
 @{Name='graphics_card_common'; File='exec-bf98b88e-b7fc-48b5-a89a-230cd724b2d9.png'; Key=$false},
 @{Name='graphics_card_premium'; File='exec-8a3c6a76-748e-4aea-9e0f-3e6e50c1dce2.png'; Key=$true},
 @{Name='mouse_common'; File='exec-b33638a8-ad2f-47c2-afb8-97b70c4c841c.png'; Key=$false},
 @{Name='keyboard_common'; File='exec-88b300f1-0280-47d8-a82f-e6c13a26cafe.png'; Key=$false}
)
# These v2 output files were created by this script during this task.
$preview = [System.Drawing.Bitmap]::new(768,768)
$pg = [System.Drawing.Graphics]::FromImage($preview)
$pg.Clear([System.Drawing.Color]::FromArgb(230,230,230))
$pg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$pg.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$index=0
foreach ($item in $items) {
 $src = [System.Drawing.Bitmap]::FromFile((Join-Path $genFolder $item.File))
 $clean = [System.Drawing.Bitmap]::new($src.Width,$src.Height,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
 $cg = [System.Drawing.Graphics]::FromImage($clean)
 $cg.CompositingMode=[System.Drawing.Drawing2D.CompositingMode]::SourceCopy
 $cg.DrawImageUnscaled($src,0,0)
 $cg.Dispose()
 $src.Dispose()
 if ($item.Key) {
  for($y=0;$y -lt $clean.Height;$y++) { for($x=0;$x -lt $clean.Width;$x++) {
   $c=$clean.GetPixel($x,$y)
   if ($c.R -gt ($c.G+10) -and $c.B -gt ($c.G+10)) { $clean.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(0,0,0,0)) }
  } }
 }
 if ($clean.GetPixel(0,0).A -ne 0) { throw 'Background is not transparent.' }
 $clean.Save((Join-Path $outFolder ($item.Name+'_v2_source.png')),[System.Drawing.Imaging.ImageFormat]::Png)
 foreach($size in @(128,64)) {
  $icon=[System.Drawing.Bitmap]::new($size,$size,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g=[System.Drawing.Graphics]::FromImage($icon)
  $g.CompositingMode=[System.Drawing.Drawing2D.CompositingMode]::SourceCopy
  $g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
  $g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
  $g.DrawImage($clean,[System.Drawing.Rectangle]::new(0,0,$size,$size),[System.Drawing.Rectangle]::new(0,0,$clean.Width,$clean.Height),[System.Drawing.GraphicsUnit]::Pixel)
  $g.Dispose()
  $icon.Save((Join-Path $outFolder ($item.Name+'_v2_'+$size+'x'+$size+'.png')),[System.Drawing.Imaging.ImageFormat]::Png)
  if ($size -eq 128) {
   $px=($index%2)*384
   $py=[int][Math]::Floor($index/2)*384
   $pg.DrawImage($icon,[System.Drawing.Rectangle]::new($px,$py,384,384),[System.Drawing.Rectangle]::new(0,0,128,128),[System.Drawing.GraphicsUnit]::Pixel)
  }
  Write-Output "$($item.Name) ${size}x${size} alpha=$($icon.GetPixel(0,0).A)"
  $icon.Dispose()
 }
 $clean.Dispose()
 $index++
}
$pg.Dispose()
$preview.Save($previewPath,[System.Drawing.Imaging.ImageFormat]::Png)
$preview.Dispose()
Write-Output $previewPath
