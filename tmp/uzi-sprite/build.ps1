$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=(Get-Location).Path
$dir=Join-Path $root 'tmp/uzi-sprite'
$src=[System.Drawing.Bitmap]::FromFile((Join-Path $dir 'reference-sheet.png'))
$gen=[System.Drawing.Bitmap]::FromFile('C:/Users/望兴腾/.codex/generated_images/01a03835-304f-7671-84b2-f0cb8dbe18d1/exec-21395fc1-a496-4c29-bc98-d24cf5d07fb1.png')
if($gen.Width -ne 1254 -or $gen.Height -ne 1254){throw 'Unexpected generation dimensions'}
$palette=@(
    [System.Drawing.Color]::FromArgb(255,19,22,25),
    [System.Drawing.Color]::FromArgb(255,30,36,43),
    [System.Drawing.Color]::FromArgb(255,46,56,67),
    [System.Drawing.Color]::FromArgb(255,65,77,91),
    [System.Drawing.Color]::FromArgb(255,84,99,114),
    [System.Drawing.Color]::FromArgb(255,109,124,136)
)
function Gun-Color([System.Drawing.Color]$p) {
    $average=($p.R+$p.G+$p.B)/3
    if(-not ($average -lt 93 -or ($p.B-$p.R -ge 7 -and $p.B -lt 175 -and $p.G -ge $p.R))) {
        return [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $best=$palette[0];$distance=[double]::PositiveInfinity
    foreach($c in $palette){$d=[math]::Pow($p.R-$c.R,2)+[math]::Pow($p.G-$c.G,2)+[math]::Pow($p.B-$c.B,2);if($d -lt $distance){$distance=$d;$best=$c}}
    return $best
}
$gun=[System.Drawing.Bitmap]::new(14,30,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
for($y=0;$y -lt 30;$y++){
    for($x=0;$x -lt 14;$x++){
        $gx=[int][math]::Floor(856+($x+0.5)*185/14)
        $gy=[int][math]::Floor(94+($y+0.5)*408/30)
        $gun.SetPixel($x,$y,(Gun-Color $gen.GetPixel($gx,$gy)))
    }
}
# Keep only the connected gun shape, discarding any isolated background samples.
$visited=@{};$queue=[Collections.Generic.Queue[System.Drawing.Point]]::new()
$queue.Enqueue([System.Drawing.Point]::new(7,12));$visited['7,12']=$true
while($queue.Count -gt 0){
    $p=$queue.Dequeue()
    foreach($offset in @(@(1,0),@(-1,0),@(0,1),@(0,-1))){
        $nx=$p.X+$offset[0];$ny=$p.Y+$offset[1];$key="$nx,$ny"
        if($nx -ge 0 -and $nx -lt 14 -and $ny -ge 0 -and $ny -lt 30 -and -not $visited.ContainsKey($key) -and $gun.GetPixel($nx,$ny).A -gt 0){$visited[$key]=$true;$queue.Enqueue([System.Drawing.Point]::new($nx,$ny))}
    }
}
for($y=0;$y -lt 30;$y++){for($x=0;$x -lt 14;$x++){if(-not $visited.ContainsKey("$x,$y")){$gun.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(0,0,0,0))}}}
$gun.Save((Join-Path $dir 'uzi-gun-template.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$sheet=[System.Drawing.Bitmap]::new(1152,96,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g=[System.Drawing.Graphics]::FromImage($sheet)
$g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.DrawImage($src,[System.Drawing.Rectangle]::new(0,0,1152,96),0,0,576,48,[System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
$clear=[System.Drawing.Color]::FromArgb(0,0,0,0)
$modifiedOutside=0
for($frame=0;$frame -lt 12;$frame++){
    # Remove the original revolver and its cylinder, retaining the underlying hand.
    for($oy=1;$oy -le 14;$oy++){
        foreach($ox in 34..37){
            $oldGun=($ox -eq 35 -or $ox -eq 36) -or ($oy -ge 8 -and $oy -le 11)
            if($oldGun){for($dy=0;$dy -lt 2;$dy++){for($dx=0;$dx -lt 2;$dx++){$sheet.SetPixel($frame*96+$ox*2+$dx,$oy*2+$dy,$clear)}}}
        }
    }
    for($y=0;$y -lt 30;$y++){
        for($x=0;$x -lt 14;$x++){
            $p=$gun.GetPixel($x,$y)
            if($p.A -gt 0){$sheet.SetPixel($frame*96+64+$x,1+$y,$p)}
        }
    }
    # Original skin sits in front of the grip so all frames retain the same grasp.
    for($y=22;$y -le 34;$y++){
        for($x=64;$x -le 79;$x++){
            $p=$src.GetPixel($frame*48+[int][math]::Floor($x/2),[int][math]::Floor($y/2))
            if($p.A -gt 0 -and $p.R -gt 190 -and $p.G -ge 150 -and $p.B -lt 180 -and $p.R -gt $p.G){$sheet.SetPixel($frame*96+$x,$y,$p)}
        }
    }
}
$skinChanges=0;$changes=0
for($y=0;$y -lt 96;$y++){
    for($x=0;$x -lt 1152;$x++){
        $p=$src.GetPixel([int][math]::Floor($x/2),[int][math]::Floor($y/2));$q=$sheet.GetPixel($x,$y)
        if($p.ToArgb() -ne $q.ToArgb()){
            $changes++;$localX=$x%96
            if($localX -lt 64 -or $localX -gt 79 -or $y -lt 1 -or $y -gt 31){$modifiedOutside++}
            if($p.A -gt 0 -and $p.R -gt 190 -and $p.G -ge 150 -and $p.B -lt 180 -and $p.R -gt $p.G){$skinChanges++}
        }
    }
}
if($modifiedOutside -gt 0 -or $skinChanges -gt 0){throw "Preservation check failed: outside=$modifiedOutside skin=$skinChanges"}
$sheet.Save((Join-Path $dir 'Personnage_vue_dessous_UZI.png'),[System.Drawing.Imaging.ImageFormat]::Png)

# Contact sheet, with exact pixel rendering and a separate small-scale view.
$preview=[System.Drawing.Bitmap]::new(960,732)
$g=[System.Drawing.Graphics]::FromImage($preview)
$g.Clear([System.Drawing.Color]::FromArgb(76,78,80))
$g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
$font=[System.Drawing.Font]::new('Arial',13)
for($i=0;$i -lt 12;$i++){
    $dx=($i%4)*240;$dy=[int][math]::Floor($i/4)*244
    $g.DrawString(('UZI / {0:00}' -f ($i+1)),$font,[System.Drawing.Brushes]::White,[single]($dx+12),[single]($dy+8))
    $g.DrawImage($sheet,[System.Drawing.Rectangle]::new($dx+24,$dy+32,192,192),$i*96,0,96,96,[System.Drawing.GraphicsUnit]::Pixel)
}
$preview.Save((Join-Path $dir 'uzi-12-frame-preview.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose();$preview.Dispose()
$detail=[System.Drawing.Bitmap]::new(768,560)
$g=[System.Drawing.Graphics]::FromImage($detail)
$g.Clear([System.Drawing.Color]::FromArgb(76,78,80))
$g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.DrawString('UZI',$font,[System.Drawing.Brushes]::White,24,16)
$g.DrawImage($sheet,[System.Drawing.Rectangle]::new(0,44,480,480),0,0,96,96,[System.Drawing.GraphicsUnit]::Pixel)
$brush=[System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(120,95,53))
$g.FillRectangle($brush,512,0,256,560)
$g.DrawString('SMALL SCALE',$font,[System.Drawing.Brushes]::White,548,144)
$g.DrawImage($sheet,[System.Drawing.Rectangle]::new(592,220,96,96),0,0,96,96,[System.Drawing.GraphicsUnit]::Pixel)
$detail.Save((Join-Path $dir 'uzi-closeup-preview.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose();$detail.Dispose();$brush.Dispose();$font.Dispose()
for($y=0;$y -lt 30;$y++){$row='';for($x=0;$x -lt 14;$x++){$p=$gun.GetPixel($x,$y);if($p.A -eq 0){$row+='.'}elseif($p.R -lt 40){$row+='#'}else{$row+='+'}};Write-Output $row}
Write-Output "Candidate: 1152x96, 12 frames of 96x96; weaponPixels=$($visited.Count); changedPixels=$changes; outsideWeapon=$modifiedOutside; skinChanges=$skinChanges"
$sheet.Dispose();$gun.Dispose();$src.Dispose();$gen.Dispose()
