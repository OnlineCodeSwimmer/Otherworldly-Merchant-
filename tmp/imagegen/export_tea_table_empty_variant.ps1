Add-Type -AssemblyName System.Drawing
$teaOriginalPath = 'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant\Assets\AIGC Source\Building\Object\Meeting Room\meeting_tea_table_topdown_128x64.png'
$teaEmptyPath = 'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant\Assets\AIGC Source\Building\Object\Meeting Room\meeting_tea_table_empty_topdown_512x256.png'
$teaReferencePath = 'C:\Users\望兴腾\.codex\generated_images\01a0ad86-844a-7e50-9b5e-4843c923a4c1\exec-f1571cca-4f76-4cdb-9275-20afb75f972d.png'
$teaEmptySourcePath = 'C:\Users\望兴腾\.codex\generated_images\019f896a-5eb7-7d33-9f82-498fb98a05c0\exec-b282fedc-7b44-43eb-b478-31bcbb8b8d8c.png'
if (Test-Path -LiteralPath $teaEmptyPath) { throw 'Refusing to overwrite an existing empty table.' }
$teaOriginalHash = (Get-FileHash -LiteralPath $teaOriginalPath).Hash
$teaOriginalMetaHash = (Get-FileHash -LiteralPath ($teaOriginalPath + '.meta')).Hash
$teaOriginal = [System.Drawing.Bitmap]::new($teaOriginalPath)
$teaReference = [System.Drawing.Bitmap]::new($teaReferencePath)
$teaEmptySource = [System.Drawing.Bitmap]::new($teaEmptySourcePath)
if ($teaOriginal.Width -ne 512 -or $teaOriginal.Height -ne 256) { throw 'Unexpected original sprite size.' }
if ($teaReference.Size -ne $teaEmptySource.Size) { throw 'Full-resolution edit alignment changed.' }
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
$teaDestination = [System.Drawing.Rectangle]::new([int][Math]::Floor((128 - $teaWidth) / 2) * 4, [int][Math]::Floor((64 - $teaHeight) / 2) * 4, $teaWidth * 4, $teaHeight * 4)
$teaResized = [System.Drawing.Bitmap]::new(512, 256, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$teaGraphics = [System.Drawing.Graphics]::FromImage($teaResized)
$teaGraphics.Clear([System.Drawing.Color]::Transparent)
$teaGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$teaGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$teaGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$teaGraphics.DrawImage($teaEmptySource, $teaDestination, $teaBounds, [System.Drawing.GraphicsUnit]::Pixel)
$teaOutput = [System.Drawing.Bitmap]::new($teaOriginal)
# Composite only the generated wood patches where props and their shadows were.
# This preserves the original outline, border, alpha, and all remaining wood pixels exactly.
$teaPropRegions = @(
    [System.Drawing.Rectangle]::new(278, 259, 638, 390),
    [System.Drawing.Rectangle]::new(941, 259, 208, 390)
)
$teaNativeRegions = @()
foreach ($teaRegion in $teaPropRegions) {
    $teaRegionLeft = [int][Math]::Floor($teaDestination.X + ($teaRegion.Left - $teaBounds.X) * $teaDestination.Width / $teaBounds.Width)
    $teaRegionTop = [int][Math]::Floor($teaDestination.Y + ($teaRegion.Top - $teaBounds.Y) * $teaDestination.Height / $teaBounds.Height)
    $teaRegionRight = [int][Math]::Ceiling($teaDestination.X + ($teaRegion.Right - $teaBounds.X) * $teaDestination.Width / $teaBounds.Width)
    $teaRegionBottom = [int][Math]::Ceiling($teaDestination.Y + ($teaRegion.Bottom - $teaBounds.Y) * $teaDestination.Height / $teaBounds.Height)
    $teaNativeRegion = [System.Drawing.Rectangle]::FromLTRB($teaRegionLeft, $teaRegionTop, $teaRegionRight, $teaRegionBottom)
    $teaNativeRegions += $teaNativeRegion
    for ($y = $teaNativeRegion.Top; $y -lt $teaNativeRegion.Bottom; $y++) {
        for ($x = $teaNativeRegion.Left; $x -lt $teaNativeRegion.Right; $x++) {
            $teaColor = $teaResized.GetPixel($x, $y)
            if ($teaColor.A -lt 128 -or $teaColor.R -le $teaColor.G + 5 -or $teaColor.G -le $teaColor.B + 5) { throw "Generated patch is not continuous warm wood at $x,$y" }
            $teaOutput.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $teaColor.R, $teaColor.G, $teaColor.B))
        }
    }
}
$teaOutsideChanges = 0
for ($y = 0; $y -lt 256; $y++) {
    for ($x = 0; $x -lt 512; $x++) {
        if ($teaOriginal.GetPixel($x, $y).ToArgb() -eq $teaOutput.GetPixel($x, $y).ToArgb()) { continue }
        $teaInsideRegion = $false
        foreach ($teaRegion in $teaNativeRegions) { if ($teaRegion.Contains($x, $y)) { $teaInsideRegion = $true } }
        if (-not $teaInsideRegion) { $teaOutsideChanges++ }
    }
}
if ($teaOutsideChanges -ne 0) { throw 'Pixels outside the object-removal regions changed.' }
$teaOutput.Save($teaEmptyPath, [System.Drawing.Imaging.ImageFormat]::Png)
$teaGraphics.Dispose(); $teaResized.Dispose(); $teaOutput.Dispose(); $teaOriginal.Dispose(); $teaReference.Dispose(); $teaEmptySource.Dispose()
if ((Get-FileHash -LiteralPath $teaOriginalPath).Hash -ne $teaOriginalHash -or (Get-FileHash -LiteralPath ($teaOriginalPath + '.meta')).Hash -ne $teaOriginalMetaHash) { throw 'Original table changed.' }
Write-Output "Saved $teaEmptyPath; canvas=512x256; original files untouched; outside patch changes=0; patches=$($teaNativeRegions -join ', ')"
