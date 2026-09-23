$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=(Get-Location).Path
$dir=Join-Path $root 'tmp/uzi-sprite'
$sourcePath=Join-Path $root 'Assets/Download Source/Personnage/Personnage_vue_dessous_revolver.png'
$src=[System.Drawing.Bitmap]::FromFile($sourcePath)
if($src.Width -ne 576 -or $src.Height -ne 48){throw 'Unexpected reference dimensions'}
$dst=[System.Drawing.Bitmap]::new(768,768,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g=[System.Drawing.Graphics]::FromImage($dst)
$g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.DrawImage($src,[System.Drawing.Rectangle]::new(0,0,768,768),0,0,48,48,[System.Drawing.GraphicsUnit]::Pixel)
$dst.Save((Join-Path $dir 'character-edit-target.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose();$dst.Dispose();$src.Dispose()
Copy-Item -LiteralPath $sourcePath -Destination (Join-Path $dir 'reference-sheet.png')
Copy-Item -LiteralPath ($sourcePath+'.meta') -Destination (Join-Path $dir 'reference-sheet.png.meta.backup')
Write-Output (Join-Path $dir 'character-edit-target.png')
$atlas=[System.Drawing.Bitmap]::FromFile((Join-Path $root 'Assets/Download Source/Free Pixel Gun Pack/FreePixelGunPack.png'))
$ref=[System.Drawing.Bitmap]::new(400,320,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$rg=[System.Drawing.Graphics]::FromImage($ref)
$rg.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$rg.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
$rg.DrawImage($atlas,[System.Drawing.Rectangle]::new(0,0,400,320),336,130,40,32,[System.Drawing.GraphicsUnit]::Pixel)
$ref.Save((Join-Path $dir 'uzi-style-reference.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$rg.Dispose();$ref.Dispose();$atlas.Dispose()
