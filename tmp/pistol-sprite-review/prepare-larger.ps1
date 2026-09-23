$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$dir = Join-Path (Get-Location).Path 'tmp/pistol-sprite-review'
$target = Join-Path (Get-Location).Path 'Assets/Download Source/Personnage/Personnage_vue_dessous_pistolet.png'
$backup = Join-Path $dir 'before-larger-gun.png'
if (Test-Path -LiteralPath $backup) { throw 'Backup already exists; inspect before rerunning.' }
Copy-Item -LiteralPath $target -Destination $backup
Copy-Item -LiteralPath ($target + '.meta') -Destination ($backup + '.meta.backup')
$src = [System.Drawing.Bitmap]::FromFile($target)
$dst = [System.Drawing.Bitmap]::new(768,768,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($dst)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.DrawImage($src,[System.Drawing.Rectangle]::new(0,0,768,768),0,0,48,48,[System.Drawing.GraphicsUnit]::Pixel)
$dst.Save((Join-Path $dir 'larger-gun-edit-target.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $dst.Dispose(); $src.Dispose()
Write-Output ('prepared=' + (Join-Path $dir 'larger-gun-edit-target.png'))
