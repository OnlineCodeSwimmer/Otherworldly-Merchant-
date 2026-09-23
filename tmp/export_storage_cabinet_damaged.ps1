Add-Type -AssemblyName System.Drawing
$cabinetJobs = @(
    @{ Source = 'exec-41b968f1-4d94-49ef-9a62-14a20455993f.png'; Reference = 'Assets\AIGC Source\Building\Object\storage_cabinet_topdown_512x512.png'; PixelScale = 1; Target = 'Assets\AIGC Source\Building\Object\storage_cabinet_damaged_topdown_512x512.png' },
    @{ Source = 'exec-f0e4a5c7-753c-454f-a7a2-667fe294e777.png'; Reference = 'Assets\AIGC Source\Building\Object\Front Image\storage_cabinet_single_door_front_512x512.png'; PixelScale = 4; Target = 'Assets\AIGC Source\Building\Object\Front Image\storage_cabinet_single_door_damaged_front_512x512.png' }
)
foreach ($cabinetJob in $cabinetJobs) {
    $referencePath = Join-Path (Get-Location) $cabinetJob.Reference
    $referenceHash = (Get-FileHash -LiteralPath $referencePath).Hash
    $referenceBitmap = [System.Drawing.Bitmap]::new($referencePath)
    $refLeft = $referenceBitmap.Width; $refTop = $referenceBitmap.Height; $refRight = -1; $refBottom = -1
    for ($y = 0; $y -lt $referenceBitmap.Height; $y++) {
        for ($x = 0; $x -lt $referenceBitmap.Width; $x++) {
            if ($referenceBitmap.GetPixel($x, $y).A -ge 128) {
                $refLeft = [Math]::Min($refLeft, $x); $refTop = [Math]::Min($refTop, $y)
                $refRight = [Math]::Max($refRight, $x); $refBottom = [Math]::Max($refBottom, $y)
            }
        }
    }
    if ($refRight -lt 0) { throw 'No reference cabinet pixels found.' }
    $sourcePath = Join-Path 'C:\Users\望兴腾\.codex\generated_images\01a0ae4a-d442-7940-b14a-26c7fe151872' $cabinetJob.Source
    $sourceBitmap = [System.Drawing.Bitmap]::new($sourcePath)
    $left = $sourceBitmap.Width; $top = $sourceBitmap.Height; $right = -1; $bottom = -1
    for ($y = 0; $y -lt $sourceBitmap.Height; $y++) {
        for ($x = 0; $x -lt $sourceBitmap.Width; $x++) {
            $pixel = $sourceBitmap.GetPixel($x, $y)
            if ($pixel.A -ge 128) {
                $sourceBitmap.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $pixel.R, $pixel.G, $pixel.B))
                $left = [Math]::Min($left, $x); $top = [Math]::Min($top, $y)
                $right = [Math]::Max($right, $x); $bottom = [Math]::Max($bottom, $y)
            } else { $sourceBitmap.SetPixel($x, $y, [System.Drawing.Color]::Transparent) }
        }
    }
    if ($right -lt 0) { throw 'No damaged cabinet pixels found.' }
    $bounds = [System.Drawing.Rectangle]::new($left, $top, $right - $left + 1, $bottom - $top + 1)
    $logicalSize = [int](512 / $cabinetJob.PixelScale)
    $logicalLeft = [int][Math]::Round($refLeft / $cabinetJob.PixelScale)
    $logicalTop = [int][Math]::Round($refTop / $cabinetJob.PixelScale)
    $logicalWidth = [int][Math]::Round(($refRight - $refLeft + 1) / $cabinetJob.PixelScale)
    $logicalHeight = [int][Math]::Round(($refBottom - $refTop + 1) / $cabinetJob.PixelScale)
    # Align the exported state to the intact sprite's occupied rectangle and pixel grid.
    $destination = [System.Drawing.Rectangle]::new($logicalLeft, $logicalTop, $logicalWidth, $logicalHeight)
    $logicalBitmap = [System.Drawing.Bitmap]::new($logicalSize, $logicalSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $logicalGraphics = [System.Drawing.Graphics]::FromImage($logicalBitmap)
    $logicalGraphics.Clear([System.Drawing.Color]::Transparent)
    $logicalGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $logicalGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $logicalGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $logicalGraphics.DrawImage($sourceBitmap, $destination, $bounds, [System.Drawing.GraphicsUnit]::Pixel)
    $outputBitmap = [System.Drawing.Bitmap]::new(512, 512, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $outputGraphics = [System.Drawing.Graphics]::FromImage($outputBitmap)
    $outputGraphics.Clear([System.Drawing.Color]::Transparent)
    $outputGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $outputGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $outputGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $outputGraphics.DrawImage($logicalBitmap, [System.Drawing.Rectangle]::new(0, 0, 512, 512), [System.Drawing.Rectangle]::new(0, 0, $logicalSize, $logicalSize), [System.Drawing.GraphicsUnit]::Pixel)
    $targetPath = Join-Path (Get-Location) $cabinetJob.Target
    if (Test-Path -LiteralPath $targetPath) { throw "Refusing to overwrite: $targetPath" }
    $outputBitmap.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output "Saved: $targetPath; canvas=512x512; sprite=$($logicalWidth*$cabinetJob.PixelScale)x$($logicalHeight*$cabinetJob.PixelScale); cornerAlpha=$($outputBitmap.GetPixel(0,0).A)"
    $outputGraphics.Dispose(); $logicalGraphics.Dispose(); $outputBitmap.Dispose(); $logicalBitmap.Dispose(); $sourceBitmap.Dispose(); $referenceBitmap.Dispose()
    if ((Get-FileHash -LiteralPath $referencePath).Hash -ne $referenceHash) { throw 'Intact sprite was unexpectedly changed.' }
}
