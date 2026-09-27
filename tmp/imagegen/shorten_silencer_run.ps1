param([switch]$Install)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$assetPath = 'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant\Assets\AIGC Source\Enemy\Silencer\Silencer_Run.png'
$outDir = 'C:\Users\望兴腾\.codex\visualizations\2026\09\27\01a0e2f9-6c16-77e3-93cb-9192d84247fe'
$backupPath = Join-Path $outDir 'Silencer_Run_before_shortening.png'
if (-not (Test-Path -LiteralPath $backupPath)) { Copy-Item -LiteralPath $assetPath -Destination $backupPath }
$source = [System.Drawing.Bitmap]::new($backupPath)
$result = $source.Clone([System.Drawing.Rectangle]::new(0, 0, 192, 48), [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
# This band is below the body and feet in all four frames: only arms occupy it.
for ($frame = 0; $frame -lt 4; $frame++) {
    for ($y = 30; $y -lt 48; $y++) {
        for ($x = 0; $x -lt 48; $x++) {
            $px = $frame * 48 + $x
            if ($y -lt 40) {
                $result.SetPixel($px, $y, $source.GetPixel($px, $y + 8))
            } else {
                $result.SetPixel($px, $y, [System.Drawing.Color]::Transparent)
            }
        }
    }
}
for ($y = 0; $y -lt 30; $y++) {
    for ($x = 0; $x -lt 192; $x++) {
        if ($source.GetPixel($x,$y).ToArgb() -ne $result.GetPixel($x,$y).ToArgb()) { throw 'Body pixels changed' }
    }
}
$outputPath = Join-Path $outDir 'silencer_run_short.png'
$result.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$preview = [System.Drawing.Bitmap]::new(1536,384)
$g = [System.Drawing.Graphics]::FromImage($preview)
$g.Clear([System.Drawing.Color]::FromArgb(150,154,158))
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.DrawImage($result,[System.Drawing.Rectangle]::new(0,0,1536,384))
$preview.Save((Join-Path $outDir 'silencer_run_short_preview.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$preview.Dispose()
$source.Dispose()
$result.Dispose()
Write-Output 'Shortened forward arm reach by 8px; all pixels above y=30 unchanged.'
if ($Install) {
    $metaHash = (Get-FileHash -LiteralPath "$assetPath.meta").Hash
    Copy-Item -LiteralPath $outputPath -Destination $assetPath -Force
    if ((Get-FileHash -LiteralPath "$assetPath.meta").Hash -ne $metaHash) { throw 'Metadata changed' }
    Write-Output 'Run PNG replaced; Unity metadata unchanged.'
}
