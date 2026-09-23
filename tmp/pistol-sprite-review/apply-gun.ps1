$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = (Get-Location).Path
$review = Join-Path $root 'tmp/pistol-sprite-review'
$target = Join-Path $root 'Assets/Download Source/Personnage/Personnage_vue_dessous_pistolet.png'
$backup = Join-Path $review 'original.png'
$candidate = Join-Path $review 'corrected.png'
$generatedPath = 'C:/Users/望兴腾/.codex/generated_images/01a03835-304f-7671-84b2-f0cb8dbe18d1/exec-c6b9ee89-302c-400a-96cf-9c6d7e7bb9d0.png'
if ((Get-FileHash -LiteralPath $target).Hash -ne (Get-FileHash -LiteralPath $backup).Hash) { throw 'Source changed since review; will not overwrite.' }
$metaHash = (Get-FileHash -LiteralPath ($target+'.meta')).Hash
Copy-Item -LiteralPath ($target+'.meta') -Destination (Join-Path $review 'original.png.meta.backup')
$original = [System.Drawing.Bitmap]::FromFile($backup)
$generated = [System.Drawing.Bitmap]::FromFile($generatedPath)
$edited = [System.Drawing.Bitmap]::new($original)
$gun = [System.Drawing.Color[]]::new(20)
for ($y=0; $y -lt 10; $y++) {
    for ($x=0; $x -lt 2; $x++) {
        $sx = [int][math]::Floor((35+$x+0.5)*$generated.Width/48)
        $sy = [int][math]::Floor((5+$y+0.5)*$generated.Height/48)
        $c = $generated.GetPixel($sx,$sy)
        if ($c.A -ne 255 -or $c.R -gt 160 -or $c.G -gt 160 -or $c.B -gt 160) { throw 'Unexpected gun-template sample.' }
        $gun[$y*2+$x]=$c
    }
}
$frameChanges = @()
for ($frame=0; $frame -lt 12; $frame++) {
    for ($y=0; $y -lt 10; $y++) {
        for ($x=0; $x -lt 2; $x++) {
            $originalPixel=$original.GetPixel($frame*48+35+$x,5+$y)
            if ($originalPixel.ToArgb() -ne $original.GetPixel(35+$x,5+$y).ToArgb()) { throw 'Original guns differ; reassess.' }
            $edited.SetPixel($frame*48+35+$x,5+$y,$gun[$y*2+$x])
        }
    }
}
$changed=0
for ($y=0; $y -lt 48; $y++) {
    for ($x=0; $x -lt 576; $x++) {
        $a=$original.GetPixel($x,$y)
        $b=$edited.GetPixel($x,$y)
        if ($a.A -ne $b.A) { throw 'Transparency changed.' }
        if ($a.ToArgb() -ne $b.ToArgb()) {
            if (($x%48) -lt 35 -or ($x%48) -gt 36 -or $y -lt 5 -or $y -gt 14) { throw 'Pixel outside gun changed.' }
            $changed++
        }
    }
}
$edited.Save($candidate,[System.Drawing.Imaging.ImageFormat]::Png)
$sheet = [System.Drawing.Bitmap]::new(1152,888)
$g = [System.Drawing.Graphics]::FromImage($sheet)
$g.Clear([System.Drawing.Color]::FromArgb(85,85,85))
$g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
$font=[System.Drawing.Font]::new('Arial',14)
for ($i=0; $i -lt 12; $i++) {
    $dx=($i%4)*288; $dy=[math]::Floor($i/4)*296
    $g.DrawString(('Frame {0}' -f ($i+1)),$font,[System.Drawing.Brushes]::White,[single]($dx+10),[single]($dy+3))
    $g.DrawImage($edited,[System.Drawing.Rectangle]::new($dx,$dy+26,288,264),$i*48,0,48,44,[System.Drawing.GraphicsUnit]::Pixel)
}
$sheet.Save((Join-Path $review 'after-contact.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$font.Dispose(); $g.Dispose(); $sheet.Dispose(); $edited.Dispose(); $generated.Dispose(); $original.Dispose()
Write-Output ('candidate={0}; changedPixels={1}; outsideGunChanges=0; alphaChanges=0; gunSize=2x10; frames=12; metaSHA256={2}' -f $candidate,$changed,$metaHash)
