$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$original=[System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'tmp/pistol-sprite-review/original.png'))
$frame=[System.Drawing.Bitmap]::new(768,768)
$g=[System.Drawing.Graphics]::FromImage($frame)
$g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.Clear([System.Drawing.Color]::Transparent)
$g.DrawImage($original,[System.Drawing.Rectangle]::new(0,0,768,768),0,0,48,48,[System.Drawing.GraphicsUnit]::Pixel)
$frame.Save((Join-Path (Get-Location) 'tmp/pistol-sprite-review/frame1-reference.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $frame.Dispose(); $original.Dispose()
