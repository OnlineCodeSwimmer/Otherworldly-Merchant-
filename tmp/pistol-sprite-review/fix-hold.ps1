$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = (Get-Location).Path
$target = Join-Path $root 'Assets/Download Source/Personnage/Personnage_vue_dessous_pistolet.png'
$review = Join-Path $root 'tmp/pistol-sprite-review'
$before = Join-Path $review 'before-hold-fix.png'
$preview = Join-Path $review 'hold-fix-preview.png'

$metaHashBefore = (Get-FileHash -LiteralPath ($target + '.meta')).Hash
Copy-Item -LiteralPath $target -Destination $before -Force

$source = [System.Drawing.Bitmap]::FromFile($target)
if ($source.Width -ne 576 -or $source.Height -ne 48) {
    throw "Unexpected sprite-sheet size: $($source.Width)x$($source.Height)"
}

$edited = [System.Drawing.Bitmap]::new($source)

# Exact two-pixel vertical gun sampled from the user's approved reference:
# a readable medium-grey face on the left and a dark edge on the right.
$left = @(
    '#494B4D', '#737577', '#727576', '#717476', '#707274',
    '#727576', '#707275', '#707375', '#707274', '#727476'
)
$right = @(
    '#2D2F31', '#424547', '#414446', '#434547', '#424447',
    '#404346', '#424648', '#414446', '#434548', '#434547'
)

function Parse-Color([string]$hex) {
    return [System.Drawing.Color]::FromArgb(
        255,
        [Convert]::ToInt32($hex.Substring(1,2),16),
        [Convert]::ToInt32($hex.Substring(3,2),16),
        [Convert]::ToInt32($hex.Substring(5,2),16)
    )
}

for ($frame = 0; $frame -lt 12; $frame++) {
    for ($dy = 0; $dy -lt 10; $dy++) {
        $edited.SetPixel($frame * 48 + 35, 5 + $dy, (Parse-Color $left[$dy]))
        $edited.SetPixel($frame * 48 + 36, 5 + $dy, (Parse-Color $right[$dy]))
    }
}

# Frame 10 alone had a stray black pixel directly touching the lower-left side
# of the gun. It made the gun/hand silhouette look thicker than every other frame.
$edited.SetPixel(9 * 48 + 34, 12, [System.Drawing.Color]::FromArgb(0,0,0,0))

$changed = @()
for ($y = 0; $y -lt 48; $y++) {
    for ($x = 0; $x -lt 576; $x++) {
        if ($source.GetPixel($x,$y).ToArgb() -ne $edited.GetPixel($x,$y).ToArgb()) {
            $changed += [PSCustomObject]@{ X=$x; Y=$y; Frame=[math]::Floor($x/48)+1; LocalX=$x%48 }
        }
    }
}

foreach ($p in $changed) {
    $isGun = $p.LocalX -ge 35 -and $p.LocalX -le 36 -and $p.Y -ge 5 -and $p.Y -le 14
    $isStray = $p.Frame -eq 10 -and $p.LocalX -eq 34 -and $p.Y -eq 12
    if (-not ($isGun -or $isStray)) {
        throw "Unexpected changed pixel: frame=$($p.Frame), x=$($p.LocalX), y=$($p.Y)"
    }
}

$source.Dispose()
$edited.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)

# Create a large nearest-neighbour contact sheet for visual verification.
$sheet = [System.Drawing.Bitmap]::new(1152, 888)
$g = [System.Drawing.Graphics]::FromImage($sheet)
$g.Clear([System.Drawing.Color]::FromArgb(85,85,85))
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$font = [System.Drawing.Font]::new('Arial',14)
for ($frame = 0; $frame -lt 12; $frame++) {
    $dx = ($frame % 4) * 288
    $dy = [math]::Floor($frame / 4) * 296
    $g.DrawString(('Frame {0}' -f ($frame + 1)), $font, [System.Drawing.Brushes]::White, [single]($dx + 10), [single]($dy + 3))
    $g.DrawImage($edited, [System.Drawing.Rectangle]::new($dx,$dy+26,288,264), $frame*48,0,48,44, [System.Drawing.GraphicsUnit]::Pixel)
}
$sheet.Save($preview, [System.Drawing.Imaging.ImageFormat]::Png)

$font.Dispose()
$g.Dispose()
$sheet.Dispose()
$edited.Dispose()

$metaHashAfter = (Get-FileHash -LiteralPath ($target + '.meta')).Hash
if ($metaHashAfter -ne $metaHashBefore) { throw 'Unity .meta file changed unexpectedly.' }

Write-Output ("target={0}" -f $target)
Write-Output ("changedPixels={0}" -f $changed.Count)
Write-Output 'allowedRegionOnly=True'
Write-Output 'all12GunTemplatesIdentical=True'
Write-Output 'frame10StrayPixelRemoved=True'
Write-Output ("metaUnchanged={0}" -f ($metaHashAfter -eq $metaHashBefore))
Write-Output ("preview={0}" -f $preview)
