Add-Type -AssemblyName System.Drawing
$teaTarget = 'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant\Assets\AIGC Source\Building\Object\Meeting Room\meeting_tea_table_topdown_128x64.png'
$teaReferencePath = 'C:\Users\望兴腾\.codex\generated_images\01a0ad86-844a-7e50-9b5e-4843c923a4c1\exec-f1571cca-4f76-4cdb-9275-20afb75f972d.png'
$teaEditedPath = 'C:\Users\望兴腾\.codex\generated_images\019f896a-5eb7-7d33-9f82-498fb98a05c0\exec-f441817f-c4a1-4fae-ad1b-1aa48b2daa6e.png'
$teaCurrent = [System.Drawing.Bitmap]::new($teaTarget)
if ($teaCurrent.Width -ne 128 -or $teaCurrent.Height -ne 64) { throw 'Expected the original 128x64 sprite.' }
$teaCurrent.Dispose()
$teaMeta = Get-Content -Raw -LiteralPath ($teaTarget + '.meta')
if ($teaMeta -notmatch '(?m)^  spritePixelsToUnits: 48\r?$') { throw 'Unexpected current PPU; do not change scene size.' }
$teaBackup = Join-Path $PSScriptRoot 'meeting_tea_table_empty_cups_before_resolution_upgrade.png'
if (Test-Path -LiteralPath $teaBackup) { throw 'Backup already exists; inspect before repeating.' }
Copy-Item -LiteralPath $teaTarget -Destination $teaBackup
Copy-Item -LiteralPath ($teaTarget + '.meta') -Destination ($teaBackup + '.meta')
$teaReference = [System.Drawing.Bitmap]::new($teaReferencePath)
$teaEdited = [System.Drawing.Bitmap]::new($teaEditedPath)
if ($teaReference.Size -ne $teaEdited.Size) { throw 'Full-resolution source alignment changed.' }
$teaLeft = $teaReference.Width; $teaTop = $teaReference.Height; $teaRight = -1; $teaBottom = -1
for ($y = 0; $y -lt $teaReference.Height; $y++) {
    for ($x = 0; $x -lt $teaReference.Width; $x++) {
        if ($teaReference.GetPixel($x, $y).A -ge 128) {
            $teaLeft = [Math]::Min($teaLeft, $x); $teaTop = [Math]::Min($teaTop, $y)
            $teaRight = [Math]::Max($teaRight, $x); $teaBottom = [Math]::Max($teaBottom, $y)
        }
        $teaColor = $teaEdited.GetPixel($x, $y)
        if ($teaColor.A -ge 128) {
            $teaEdited.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $teaColor.R, $teaColor.G, $teaColor.B))
        } else { $teaEdited.SetPixel($x, $y, [System.Drawing.Color]::Transparent) }
    }
}
$teaBounds = [System.Drawing.Rectangle]::new($teaLeft, $teaTop, $teaRight - $teaLeft + 1, $teaBottom - $teaTop + 1)
$teaScale = [Math]::Min(124.0 / $teaBounds.Width, 60.0 / $teaBounds.Height)
$teaNativeWidth = [int][Math]::Round($teaBounds.Width * $teaScale)
$teaNativeHeight = [int][Math]::Round($teaBounds.Height * $teaScale)
$teaNativeX = [int][Math]::Floor((128 - $teaNativeWidth) / 2)
$teaNativeY = [int][Math]::Floor((64 - $teaNativeHeight) / 2)
$teaDestination = [System.Drawing.Rectangle]::new($teaNativeX * 4, $teaNativeY * 4, $teaNativeWidth * 4, $teaNativeHeight * 4)
$teaOutput = [System.Drawing.Bitmap]::new(512, 256, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$teaGraphics = [System.Drawing.Graphics]::FromImage($teaOutput)
$teaGraphics.Clear([System.Drawing.Color]::Transparent)
$teaGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$teaGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$teaGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$teaGraphics.DrawImage($teaEdited, $teaDestination, $teaBounds, [System.Drawing.GraphicsUnit]::Pixel)
$teaOutput.Save($teaTarget, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Overwrote $teaTarget; canvas=512x256; object=$($teaDestination.Width)x$($teaDestination.Height); alpha=$($teaOutput.GetPixel(0,0).A); backup=$teaBackup; required PPU=192"
$teaGraphics.Dispose(); $teaOutput.Dispose(); $teaReference.Dispose(); $teaEdited.Dispose()
