$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$projectRoot = (Get-Location).Path
$outputDir = Join-Path $projectRoot 'output/imagegen/inventory_rows_29_36'
$manifest = Get-Content -LiteralPath (Join-Path $outputDir 'generation_manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$stageDir = Join-Path $outputDir 'sprites'
[void][IO.Directory]::CreateDirectory($stageDir)
$preview = [Drawing.Bitmap]::new(1280,680,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
$pg = [Drawing.Graphics]::FromImage($preview)
$pg.Clear([Drawing.Color]::FromArgb(41,45,50))
$pg.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$pg.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
$font = [Drawing.Font]::new('Arial',12)
$index = 0
foreach ($item in $manifest.items) {
  $source = [Drawing.Bitmap]::new([string]$item.source)
  $icon = [Drawing.Bitmap]::new([int]$item.w,[int]$item.h,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [Drawing.Graphics]::FromImage($icon)
  $g.CompositingMode = [Drawing.Drawing2D.CompositingMode]::SourceCopy
  $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
  $g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
  $g.DrawImage($source,[Drawing.Rectangle]::new(0,0,$icon.Width,$icon.Height),[Drawing.Rectangle]::new(0,0,$source.Width,$source.Height),[Drawing.GraphicsUnit]::Pixel)
  $g.Dispose()
  $source.Dispose()
  $opaque = 0
  $transparent = 0
  for ($y=0; $y -lt $icon.Height; $y++) {
    for ($x=0; $x -lt $icon.Width; $x++) {
      $color = $icon.GetPixel($x,$y)
      if ($color.A -lt 128) {
        $icon.SetPixel($x,$y,[Drawing.Color]::FromArgb(0,0,0,0))
        $transparent++
      } else {
        $icon.SetPixel($x,$y,[Drawing.Color]::FromArgb(255,$color.R,$color.G,$color.B))
        $opaque++
      }
    }
  }
  if ($opaque -eq 0 -or $transparent -eq 0) { throw ('Invalid alpha: ' + $item.id) }
  $icon.Save((Join-Path $stageDir $item.filename),[Drawing.Imaging.ImageFormat]::Png)
  $col = $index % 4
  $row = [int][Math]::Floor($index / 4)
  $zoom = if ($icon.Width -eq 128) { 2 } else { 3 }
  $dw = $icon.Width * $zoom
  $dh = $icon.Height * $zoom
  $left = [int]($col*320 + (320-$dw)/2)
  $top = [int]($row*340 + 35 + (260-$dh)/2)
  $pg.DrawImage($icon,[Drawing.Rectangle]::new($left,$top,$dw,$dh),[Drawing.Rectangle]::new(0,0,$icon.Width,$icon.Height),[Drawing.GraphicsUnit]::Pixel)
  $label = $item.id + '  ' + ($item.name -replace '_',' ')
  $pg.DrawString($label,$font,[Drawing.Brushes]::Gainsboro,($col*320+12),($row*340+302))
  Write-Output ($item.filename + ' opaque=' + $opaque + ' transparent=' + $transparent)
  $icon.Dispose()
  $index++
}
$font.Dispose()
$pg.Dispose()
$preview.Save((Join-Path $outputDir 'inventory_0027_0034_preview.png'),[Drawing.Imaging.ImageFormat]::Png)
$preview.Dispose()
