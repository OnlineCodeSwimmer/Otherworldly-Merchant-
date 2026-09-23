Add-Type -AssemblyName System.Drawing
$cabinetJobs = @(
    @{ Source = 'exec-8ef926c8-dae4-4868-9b10-8b00e81d57e8.png'; LogicalWidth = 192; LogicalHeight = 128; MaxWidth = 168.0; MaxHeight = 116.0; Zoom = 4; Target = 'Assets\AIGC Source\Building\Object\Front Image\storage_cabinet_triple_front_768x512.png' },
    @{ Source = 'exec-d70130f4-498e-4630-8d14-e4f755704060.png'; LogicalWidth = 320; LogicalHeight = 128; MaxWidth = 270.0; MaxHeight = 112.0; Zoom = 1; Target = 'Assets\AIGC Source\Building\Object\storage_cabinet_triple_topdown_320x128.png' }
)
foreach ($cabinetJob in $cabinetJobs) {
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
    if ($right -lt 0) { throw 'No opaque cabinet pixels found.' }
    $bounds = [System.Drawing.Rectangle]::new($left, $top, $right - $left + 1, $bottom - $top + 1)
    $scale = [Math]::Min($cabinetJob.MaxWidth / $bounds.Width, $cabinetJob.MaxHeight / $bounds.Height)
    $width = [int][Math]::Round($bounds.Width * $scale)
    $height = [int][Math]::Round($bounds.Height * $scale)
    $destination = [System.Drawing.Rectangle]::new([int][Math]::Floor(($cabinetJob.LogicalWidth - $width) / 2), [int][Math]::Floor(($cabinetJob.LogicalHeight - $height) / 2), $width, $height)
    $logicalBitmap = [System.Drawing.Bitmap]::new($cabinetJob.LogicalWidth, $cabinetJob.LogicalHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $logicalGraphics = [System.Drawing.Graphics]::FromImage($logicalBitmap)
    $logicalGraphics.Clear([System.Drawing.Color]::Transparent)
    $logicalGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $logicalGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $logicalGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $logicalGraphics.DrawImage($sourceBitmap, $destination, $bounds, [System.Drawing.GraphicsUnit]::Pixel)
    $canvasWidth = $cabinetJob.LogicalWidth * $cabinetJob.Zoom
    $canvasHeight = $cabinetJob.LogicalHeight * $cabinetJob.Zoom
    $outputBitmap = [System.Drawing.Bitmap]::new($canvasWidth, $canvasHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $outputGraphics = [System.Drawing.Graphics]::FromImage($outputBitmap)
    $outputGraphics.Clear([System.Drawing.Color]::Transparent)
    $outputGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $outputGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $outputGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $outputGraphics.DrawImage($logicalBitmap, [System.Drawing.Rectangle]::new(0, 0, $canvasWidth, $canvasHeight), [System.Drawing.Rectangle]::new(0, 0, $cabinetJob.LogicalWidth, $cabinetJob.LogicalHeight), [System.Drawing.GraphicsUnit]::Pixel)
    $targetPath = Join-Path (Get-Location) $cabinetJob.Target
    if (Test-Path -LiteralPath $targetPath) { throw "Refusing to overwrite: $targetPath" }
    $outputBitmap.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output "Saved: $targetPath; canvas=$($canvasWidth)x$($canvasHeight); object=$($width*$cabinetJob.Zoom)x$($height*$cabinetJob.Zoom); cornerAlpha=$($outputBitmap.GetPixel(0,0).A)"
    $outputGraphics.Dispose(); $logicalGraphics.Dispose(); $outputBitmap.Dispose(); $logicalBitmap.Dispose(); $sourceBitmap.Dispose()
}
