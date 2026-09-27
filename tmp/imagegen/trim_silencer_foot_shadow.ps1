param([switch]$Install)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$assetPath = 'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant\Assets\AIGC Source\Enemy\Silencer\Silencer.png'
$reviewDir = 'C:\Users\望兴腾\.codex\visualizations\2026\09\27\01a0e2f9-6c16-77e3-93cb-9192d84247fe'
$backupPath = Join-Path $reviewDir 'Silencer_before_precise_perimeter_trim.png'
if (-not (Test-Path -LiteralPath $backupPath)) {
    Copy-Item -LiteralPath $assetPath -Destination $backupPath
}
$original = [System.Drawing.Bitmap]::new($backupPath)
$edited = $original.Clone([System.Drawing.Rectangle]::new(0, 0, $original.Width, $original.Height), [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$changed = [System.Collections.Generic.List[string]]::new()
$leftEdges = @(18, 18, 17, 17)
$rightEdges = @(30, 30, 29, 29)
for ($frame = 0; $frame -lt 4; $frame++) {
    $points = [System.Collections.Generic.List[System.Drawing.Point]]::new()
    # Only the bottom outside rim of each foot, below the actual grey toes.
    for ($x = 17; $x -le 30; $x++) {
        $points.Add([System.Drawing.Point]::new($x, 25))
    }
    # Extra outside rim at the lateral edges. Inner foot shading is preserved.
    foreach ($y in @(23, 24)) {
        $points.Add([System.Drawing.Point]::new($leftEdges[$frame], $y))
        $points.Add([System.Drawing.Point]::new($rightEdges[$frame], $y))
    }
    foreach ($point in $points) {
        $px = $frame * 48 + $point.X
        $c = $original.GetPixel($px, $point.Y)
        if ($c.A -gt 0 -and [Math]::Max($c.R, [Math]::Max($c.G, $c.B)) -lt 65) {
            $edited.SetPixel($px, $point.Y, [System.Drawing.Color]::FromArgb(0, $c.R, $c.G, $c.B))
            $changed.Add("frame=$frame x=$($point.X) y=$($point.Y)")
        }
    }
}
$outPath = Join-Path $reviewDir 'silencer_idle_precise_foot_shadow.png'
$edited.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$preview = [System.Drawing.Bitmap]::new(1536, 384)
$g = [System.Drawing.Graphics]::FromImage($preview)
$g.Clear([System.Drawing.Color]::FromArgb(150, 154, 158))
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.DrawImage($edited, [System.Drawing.Rectangle]::new(0, 0, 1536, 384))
$preview.Save((Join-Path $reviewDir 'silencer_idle_precise_foot_shadow_preview.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$preview.Dispose()
# Verify no color or physical grey foot pixel was changed, only selected alpha.
$differenceCount = 0
for ($y = 0; $y -lt 48; $y++) {
    for ($x = 0; $x -lt 192; $x++) {
        $a = $original.GetPixel($x, $y)
        $b = $edited.GetPixel($x, $y)
        if ($a.ToArgb() -ne $b.ToArgb()) {
            $differenceCount++
            if ($a.R -ne $b.R -or $a.G -ne $b.G -or $a.B -ne $b.B -or $b.A -ne 0 -or $y -lt 23 -or $y -gt 25) {
                throw 'Unexpected change outside foot perimeter alpha.'
            }
        }
    }
}
$original.Dispose()
$edited.Dispose()
Write-Output "Changed $differenceCount dark perimeter pixels across four frames; all RGB and all other pixels preserved."
if ($Install) {
    $metaHash = (Get-FileHash -LiteralPath "$assetPath.meta").Hash
    Copy-Item -LiteralPath $outPath -Destination $assetPath -Force
    if ((Get-FileHash -LiteralPath "$assetPath.meta").Hash -ne $metaHash) { throw 'Metadata changed' }
    Write-Output 'Installed, Unity metadata unchanged.'
}
