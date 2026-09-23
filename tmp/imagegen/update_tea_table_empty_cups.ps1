Add-Type -AssemblyName System.Drawing
$teaTarget = 'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant\Assets\AIGC Source\Building\Object\Meeting Room\meeting_tea_table_topdown_128x64.png'
$teaReferencePath = 'C:\Users\望兴腾\.codex\generated_images\01a0ad86-844a-7e50-9b5e-4843c923a4c1\exec-f1571cca-4f76-4cdb-9275-20afb75f972d.png'
$teaEditedPath = 'C:\Users\望兴腾\.codex\generated_images\019f896a-5eb7-7d33-9f82-498fb98a05c0\exec-f441817f-c4a1-4fae-ad1b-1aa48b2daa6e.png'
$teaMetaHash = (Get-FileHash -LiteralPath ($teaTarget + '.meta')).Hash
$teaBackup = Join-Path $PSScriptRoot 'meeting_tea_table_before_empty_cups.png'
if (-not (Test-Path -LiteralPath $teaBackup)) { Copy-Item -LiteralPath $teaTarget -Destination $teaBackup }
$teaOriginal = [System.Drawing.Bitmap]::new($teaTarget)
$teaOutput = [System.Drawing.Bitmap]::new($teaOriginal)
$teaReference = [System.Drawing.Bitmap]::new($teaReferencePath)
$teaEdited = [System.Drawing.Bitmap]::new($teaEditedPath)
if ($teaOriginal.Width -ne 128 -or $teaOriginal.Height -ne 64) { throw 'Unexpected target dimensions.' }
if ($teaReference.Size -ne $teaEdited.Size) { throw 'Edit alignment requires matching full-resolution canvases.' }
$teaLeft = $teaReference.Width; $teaTop = $teaReference.Height; $teaRight = -1; $teaBottom = -1
for ($y = 0; $y -lt $teaReference.Height; $y++) {
    for ($x = 0; $x -lt $teaReference.Width; $x++) {
        if ($teaReference.GetPixel($x, $y).A -ge 128) {
            $teaLeft = [Math]::Min($teaLeft, $x); $teaTop = [Math]::Min($teaTop, $y)
            $teaRight = [Math]::Max($teaRight, $x); $teaBottom = [Math]::Max($teaBottom, $y)
        }
    }
}
$teaBounds = [System.Drawing.Rectangle]::new($teaLeft, $teaTop, $teaRight - $teaLeft + 1, $teaBottom - $teaTop + 1)
$teaScale = [Math]::Min(124.0 / $teaBounds.Width, 60.0 / $teaBounds.Height)
$teaWidth = [int][Math]::Round($teaBounds.Width * $teaScale)
$teaHeight = [int][Math]::Round($teaBounds.Height * $teaScale)
$teaDestination = [System.Drawing.Rectangle]::new([int][Math]::Floor((128 - $teaWidth) / 2), [int][Math]::Floor((64 - $teaHeight) / 2), $teaWidth, $teaHeight)
$teaResized = [System.Drawing.Bitmap]::new(128, 64, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$teaGraphics = [System.Drawing.Graphics]::FromImage($teaResized)
$teaGraphics.Clear([System.Drawing.Color]::Transparent)
$teaGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$teaGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$teaGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$teaGraphics.DrawImage($teaEdited, $teaDestination, $teaBounds, [System.Drawing.GraphicsUnit]::Pixel)
$teaRegions = @(
    [System.Drawing.Rectangle]::new(45, 20, 12, 12),
    [System.Drawing.Rectangle]::new(37, 32, 13, 13),
    [System.Drawing.Rectangle]::new(49, 32, 13, 13)
)
$teaChanges = @(0, 0, 0)
for ($i = 0; $i -lt $teaRegions.Count; $i++) {
    $teaRegion = $teaRegions[$i]
    for ($y = $teaRegion.Top; $y -lt $teaRegion.Bottom; $y++) {
        for ($x = $teaRegion.Left; $x -lt $teaRegion.Right; $x++) {
            $teaColor = $teaOriginal.GetPixel($x, $y)
            if ($teaColor.A -ge 128 -and $teaColor.R -gt $teaColor.G + 12 -and $teaColor.G -gt $teaColor.B + 12) {
                $teaReplacement = $teaResized.GetPixel($x, $y)
                if ($teaReplacement.A -lt 128 -or [Math]::Abs([int]$teaReplacement.R - [int]$teaReplacement.B) -gt 35) { throw "Invalid empty cup color at $x,$y" }
                $teaOutput.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $teaReplacement.R, $teaReplacement.G, $teaReplacement.B))
                $teaChanges[$i]++
            }
        }
    }
    if ($teaChanges[$i] -lt 8) { throw "Cup $i did not have enough liquid pixels." }
}
$teaDifferenceCount = 0
for ($y = 0; $y -lt 64; $y++) {
    for ($x = 0; $x -lt 128; $x++) {
        if ($teaOriginal.GetPixel($x, $y).ToArgb() -ne $teaOutput.GetPixel($x, $y).ToArgb()) { $teaDifferenceCount++ }
    }
}
if ($teaDifferenceCount -ne ($teaChanges | Measure-Object -Sum).Sum) { throw 'Unexpected pixels changed outside the liquid mask.' }
$teaOriginal.Dispose()
$teaOutput.Save($teaTarget, [System.Drawing.Imaging.ImageFormat]::Png)
$teaGraphics.Dispose(); $teaResized.Dispose(); $teaOutput.Dispose(); $teaReference.Dispose(); $teaEdited.Dispose()
if ((Get-FileHash -LiteralPath ($teaTarget + '.meta')).Hash -ne $teaMetaHash) { throw 'Unity importer metadata changed.' }
Write-Output "Saved $teaTarget; canvas=128x64; liquid pixels changed per cup=$($teaChanges -join ','); other pixels unchanged; meta unchanged; backup=$teaBackup"
