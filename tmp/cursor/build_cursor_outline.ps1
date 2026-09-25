$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = (Get-Location).Path
$sourcePath = Join-Path $root 'output/imagegen/cursor_outline_fix/crosshair_edit_source.png'
$targetPath = Join-Path $root 'Assets/AIGC Source/Cursor/Crosshair_Outlined_64x64.png'
$previewPath = Join-Path $root 'output/imagegen/cursor_outline_fix/crosshair_64x64_preview.png'
[void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($targetPath))

$source = [Drawing.Bitmap]::new($sourcePath)
$size = 64
$sampled = [bool[,]]::new($size,$size)
for ($y=0; $y -lt $size; $y++) {
  for ($x=0; $x -lt $size; $x++) {
    $isWhite = $false
    foreach ($offsetY in @(-0.2,0,0.2)) {
      foreach ($offsetX in @(-0.2,0,0.2)) {
        $sx = [Math]::Clamp([int][Math]::Floor(($x+0.5+$offsetX)*$source.Width/$size),0,$source.Width-1)
        $sy = [Math]::Clamp([int][Math]::Floor(($y+0.5+$offsetY)*$source.Height/$size),0,$source.Height-1)
        $c = $source.GetPixel($sx,$sy)
        if ($c.A -ge 160 -and $c.R -ge 190 -and $c.G -ge 190 -and $c.B -ge 190) { $isWhite = $true }
      }
    }
    $sampled[$x,$y] = $isWhite
  }
}
$source.Dispose()

# Mirror and rotate the repaired source to make all four arms identical.
$white = [bool[,]]::new($size,$size)
for ($y=0; $y -lt $size; $y++) {
  for ($x=0; $x -lt $size; $x++) {
    $rx = $size-1-$x
    $ry = $size-1-$y
    $white[$x,$y] = $sampled[$x,$y] -or $sampled[$rx,$y] -or $sampled[$x,$ry] -or $sampled[$rx,$ry] -or
                    $sampled[$y,$x] -or $sampled[$ry,$x] -or $sampled[$y,$rx] -or $sampled[$ry,$rx]
  }
}

$icon = [Drawing.Bitmap]::new($size,$size,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
$whiteCount = 0
$blackCount = 0
for ($y=0; $y -lt $size; $y++) {
  for ($x=0; $x -lt $size; $x++) {
    if ($white[$x,$y]) {
      $icon.SetPixel($x,$y,[Drawing.Color]::White)
      $whiteCount++
      continue
    }
    $touchesWhite = $false
    for ($dy=-1; $dy -le 1; $dy++) {
      for ($dx=-1; $dx -le 1; $dx++) {
        $nx=$x+$dx; $ny=$y+$dy
        if ($nx -ge 0 -and $nx -lt $size -and $ny -ge 0 -and $ny -lt $size -and $white[$nx,$ny]) { $touchesWhite = $true }
      }
    }
    if ($touchesWhite) {
      $icon.SetPixel($x,$y,[Drawing.Color]::Black)
      $blackCount++
    }
  }
}
if ($whiteCount -lt 100 -or $blackCount -lt 100 -or $icon.GetPixel(0,0).A -ne 0) { throw 'Cursor image failed validation' }
$icon.Save($targetPath,[Drawing.Imaging.ImageFormat]::Png)

$preview = [Drawing.Bitmap]::new(512,512,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [Drawing.Graphics]::FromImage($preview)
$graphics.Clear([Drawing.Color]::FromArgb(194,199,202))
$graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
$graphics.DrawImage($icon,[Drawing.Rectangle]::new(0,0,512,512),[Drawing.Rectangle]::new(0,0,64,64),[Drawing.GraphicsUnit]::Pixel)
$graphics.Dispose()
$preview.Save($previewPath,[Drawing.Imaging.ImageFormat]::Png)
$preview.Dispose()
$icon.Dispose()
Write-Output ('Created 64x64 cursor; white=' + $whiteCount + '; outline=' + $blackCount)
