$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$dir = Join-Path (Get-Location).Path 'tmp/pistol-sprite-review'
$sourcePath = Join-Path $dir 'before-larger-gun.png'
$generatedPath = 'C:/Users/望兴腾/.codex/generated_images/01a03835-304f-7671-84b2-f0cb8dbe18d1/exec-e5a41e9f-9b09-46b4-a76f-b398087b4ad7.png'
$source = [System.Drawing.Bitmap]::FromFile($sourcePath)
$generated = [System.Drawing.Bitmap]::FromFile($generatedPath)
if ($generated.Width -ne 1254 -or $generated.Height -ne 1254) { throw 'Review generated-image crop for unexpected dimensions.' }
$edited = [System.Drawing.Bitmap]::new($source)
$template = [System.Drawing.Bitmap]::new(4,12,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
# Map only the generated slide and grip back onto the original sprite's grid.
# The surrounding generated checkerboard and character are never composited.
$palette = @(
    [System.Drawing.Color]::FromArgb(255,37,40,44),
    [System.Drawing.Color]::FromArgb(255,66,71,76),
    [System.Drawing.Color]::FromArgb(255,102,109,115),
    [System.Drawing.Color]::FromArgb(255,155,163,168)
)
function Snap-Color([System.Drawing.Color]$sample) {
    $best = $palette[0]; $distance = [double]::PositiveInfinity
    foreach ($c in $palette) {
        $d = [math]::Pow($sample.R-$c.R,2) + [math]::Pow($sample.G-$c.G,2) + [math]::Pow($sample.B-$c.B,2)
        if ($d -lt $distance) { $distance=$d; $best=$c }
    }
    return $best
}
for ($y=0; $y -lt 9; $y++) {
    for ($x=0; $x -lt 4; $x++) {
        if ($y -eq 0 -and ($x -eq 0 -or $x -eq 3)) { continue }
        $sx = [int][math]::Floor(891 + ($x+0.5)*123/4)
        $sy = [int][math]::Floor(127 + ($y+0.5)*232/9)
        $template.SetPixel($x,$y,(Snap-Color $generated.GetPixel($sx,$sy)))
    }
}
for ($y=9; $y -lt 12; $y++) {
    for ($x=1; $x -le 2; $x++) {
        $sx = [int][math]::Floor(914 + ($x-0.5)*79/2)
        $sy = [int][math]::Floor(360 + ($y-8.5)*49/3)
        $template.SetPixel($x,$y,(Snap-Color $generated.GetPixel($sx,$sy)))
    }
}
for ($frame=0; $frame -lt 12; $frame++) {
    for ($y=0; $y -lt 12; $y++) {
        for ($x=0; $x -lt 4; $x++) {
            $p=$template.GetPixel($x,$y)
            if ($p.A -gt 0) { $edited.SetPixel($frame*48+34+$x,3+$y,$p) }
        }
    }
}
$changed=0; $outside=0; $alphaAdded=0; $skinChanged=0
for ($y=0; $y -lt 48; $y++) {
    for ($x=0; $x -lt 576; $x++) {
        $a=$source.GetPixel($x,$y); $b=$edited.GetPixel($x,$y)
        if ($a.ToArgb() -ne $b.ToArgb()) {
            $changed++
            if ($x%48 -lt 34 -or $x%48 -gt 37 -or $y -lt 3 -or $y -gt 14) { $outside++ }
            if ($a.A -eq 0 -and $b.A -gt 0) { $alphaAdded++ }
            if ($a.A -gt 0 -and $a.R -gt 180 -and $a.G -gt 140 -and $a.B -lt 180) { $skinChanged++ }
        }
    }
}
if ($outside -gt 0 -or $skinChanged -gt 0) { throw 'Candidate changed pixels outside the gun or covered the hand.' }
$template.Save((Join-Path $dir 'larger-gun-template.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$edited.Save((Join-Path $dir 'larger-gun-candidate.png'),[System.Drawing.Imaging.ImageFormat]::Png)

# Comparison at an integer zoom, with a small-scale view beneath each sprite.
$compare=[System.Drawing.Bitmap]::new(800,550)
$g=[System.Drawing.Graphics]::FromImage($compare)
$g.Clear([System.Drawing.Color]::FromArgb(66,66,66))
$g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
$font=[System.Drawing.Font]::new('Arial',16)
$g.DrawString('BEFORE: 2 px wide',$font,[System.Drawing.Brushes]::White,20,12)
$g.DrawString('AFTER: 4 px wide',$font,[System.Drawing.Brushes]::White,420,12)
$g.DrawImage($source,[System.Drawing.Rectangle]::new(8,48,384,384),0,0,48,48,[System.Drawing.GraphicsUnit]::Pixel)
$g.DrawImage($edited,[System.Drawing.Rectangle]::new(408,48,384,384),0,0,48,48,[System.Drawing.GraphicsUnit]::Pixel)
$brush=[System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(117,94,53))
$g.FillRectangle($brush,0,432,800,118)
$g.DrawImage($source,[System.Drawing.Rectangle]::new(152,443,96,96),0,0,48,48,[System.Drawing.GraphicsUnit]::Pixel)
$g.DrawImage($edited,[System.Drawing.Rectangle]::new(552,443,96,96),0,0,48,48,[System.Drawing.GraphicsUnit]::Pixel)
$compare.Save((Join-Path $dir 'larger-gun-comparison.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $compare.Dispose(); $brush.Dispose()
$sheet=[System.Drawing.Bitmap]::new(960,660)
$g=[System.Drawing.Graphics]::FromImage($sheet)
$g.Clear([System.Drawing.Color]::FromArgb(66,66,66))
$g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
for ($i=0; $i -lt 12; $i++) {
    $dx=($i%4)*240; $dy=[int][math]::Floor($i/4)*220
    $g.DrawString(('Frame {0}' -f ($i+1)),$font,[System.Drawing.Brushes]::White,[single]($dx+10),[single]($dy+3))
    $g.DrawImage($edited,[System.Drawing.Rectangle]::new($dx+24,$dy+26,192,192),$i*48,0,48,48,[System.Drawing.GraphicsUnit]::Pixel)
}
$sheet.Save((Join-Path $dir 'larger-gun-12frames.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose();$sheet.Dispose();$font.Dispose()
for ($y=0;$y -lt 12;$y++) {
    $line='';for($x=0;$x -lt 4;$x++){ $p=$template.GetPixel($x,$y);if($p.A -eq 0){$line+=' . '}else{$line+=(' {0} ' -f ([array]::FindIndex($palette,[Predicate[System.Drawing.Color]]{param($c) $c.ToArgb() -eq $p.ToArgb()})))}}
    Write-Output $line
}
$source.Dispose();$generated.Dispose();$edited.Dispose();$template.Dispose()
Write-Output "changedPixels=$changed; addedOpaquePixels=$alphaAdded; outsideGunChanges=$outside; skinChanges=$skinChanged"
