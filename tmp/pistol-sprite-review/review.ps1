$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$projectRoot = (Get-Location).Path
$sourcePath = Join-Path $projectRoot 'Assets/Download Source/Personnage/Personnage_vue_dessous_pistolet.png'
$reviewRoot = Join-Path $projectRoot 'tmp/pistol-sprite-review'
$backupPath = Join-Path $reviewRoot 'original.png'
if (-not (Test-Path -LiteralPath $backupPath)) { Copy-Item -LiteralPath $sourcePath -Destination $backupPath }
$source = [System.Drawing.Bitmap]::FromFile($sourcePath)
$sheet = [System.Drawing.Bitmap]::new(1152, 888)
$g = [System.Drawing.Graphics]::FromImage($sheet)
$g.Clear([System.Drawing.Color]::FromArgb(85,85,85))
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$font = [System.Drawing.Font]::new('Arial', 14)
$palette = @{}
for ($i=0; $i -lt 12; $i++) {
    $dx = ($i % 4) * 288
    $dy = [math]::Floor($i / 4) * 296
    $g.DrawString(('Frame {0}' -f ($i+1)), $font, [System.Drawing.Brushes]::White, [single]($dx+10), [single]($dy+3))
    $g.DrawImage($source, [System.Drawing.Rectangle]::new($dx,$dy+26,288,264), $i*48,0,48,44,[System.Drawing.GraphicsUnit]::Pixel)
    $lines = @()
    for ($y=0; $y -lt 22; $y++) {
        $line=''
        for ($x=29; $x -lt 43; $x++) {
            $p=$source.GetPixel($i*48+$x,$y)
            if ($p.A -eq 0) { $line+='.'; continue }
            $key=('{0},{1},{2},{3}' -f $p.R,$p.G,$p.B,$p.A)
            if (-not $palette.ContainsKey($key)) { $palette[$key]=[string][char](65+$palette.Count) }
            $line += $palette[$key]
        }
        $lines+=('{0:D2}: {1}' -f $y,$line)
    }
    Write-Output ('FRAME '+($i+1))
    Write-Output $lines
}
$sheet.Save((Join-Path $reviewRoot 'before-contact.png'),[System.Drawing.Imaging.ImageFormat]::Png)
Write-Output ($palette | ConvertTo-Json -Compress)
$font.Dispose(); $g.Dispose(); $sheet.Dispose(); $source.Dispose()
