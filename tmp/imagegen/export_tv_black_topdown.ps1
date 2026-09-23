Add-Type -AssemblyName System.Drawing
$tvSourcePath = 'C:\Users\望兴腾\.codex\generated_images\019f896a-5eb7-7d33-9f82-498fb98a05c0\exec-8bf612b9-ce5e-41b4-a73c-45b258c191d9.png'
$tvTargetPath = 'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant\Assets\AIGC Source\Building\Object\Meeting Room\meeting_tv_black_strict_topdown_512x128.png'
if (Test-Path -LiteralPath $tvTargetPath) { throw 'Refusing to overwrite an existing television.' }
$tvSource = [System.Drawing.Bitmap]::new($tvSourcePath)
if ($tvSource.GetPixel(0,0).A -ne 0) { throw 'Source does not have genuine transparent background.' }
$tvLeft = $tvSource.Width; $tvTop = $tvSource.Height; $tvRight = -1; $tvBottom = -1
for ($y = 0; $y -lt $tvSource.Height; $y++) {
    for ($x = 0; $x -lt $tvSource.Width; $x++) {
        $tvColor = $tvSource.GetPixel($x, $y)
        if ($tvColor.A -ge 128) {
            $tvSource.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $tvColor.R, $tvColor.G, $tvColor.B))
            $tvLeft = [Math]::Min($tvLeft, $x); $tvTop = [Math]::Min($tvTop, $y)
            $tvRight = [Math]::Max($tvRight, $x); $tvBottom = [Math]::Max($tvBottom, $y)
        } else { $tvSource.SetPixel($x, $y, [System.Drawing.Color]::Transparent) }
    }
}
if ($tvRight -lt 0) { throw 'No opaque TV found.' }
$tvBounds = [System.Drawing.Rectangle]::new($tvLeft, $tvTop, $tvRight - $tvLeft + 1, $tvBottom - $tvTop + 1)
$tvScale = [Math]::Min(488.0 / $tvBounds.Width, 104.0 / $tvBounds.Height)
$tvWidth = [int][Math]::Round($tvBounds.Width * $tvScale)
$tvHeight = [int][Math]::Round($tvBounds.Height * $tvScale)
$tvDestination = [System.Drawing.Rectangle]::new([int][Math]::Floor((512 - $tvWidth) / 2), [int][Math]::Floor((128 - $tvHeight) / 2), $tvWidth, $tvHeight)
$tvOutput = [System.Drawing.Bitmap]::new(512, 128, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$tvGraphics = [System.Drawing.Graphics]::FromImage($tvOutput)
$tvGraphics.Clear([System.Drawing.Color]::Transparent)
$tvGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$tvGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$tvGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$tvGraphics.DrawImage($tvSource, $tvDestination, $tvBounds, [System.Drawing.GraphicsUnit]::Pixel)
$tvOutput.Save($tvTargetPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved: $tvTargetPath; canvas=512x128; TV footprint=$($tvWidth)x$($tvHeight); alpha=$($tvOutput.GetPixel(0,0).A)"
$tvGraphics.Dispose(); $tvOutput.Dispose(); $tvSource.Dispose()
