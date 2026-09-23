Add-Type -AssemblyName System.Drawing
$tvConsoleSourcePath = 'C:\Users\望兴腾\.codex\generated_images\019f896a-5eb7-7d33-9f82-498fb98a05c0\exec-5880c902-e19e-432d-aa74-dce179bd0966.png'
$tvConsoleTarget = 'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant\Assets\AIGC Source\Building\Object\Meeting Room\meeting_tv_console_lightwood_topdown_768x192.png'
if (Test-Path -LiteralPath $tvConsoleTarget) { throw 'Refusing to overwrite an existing TV console.' }
$tvConsoleSource = [System.Drawing.Bitmap]::new($tvConsoleSourcePath)
$tvConsoleLeft = $tvConsoleSource.Width; $tvConsoleTop = $tvConsoleSource.Height; $tvConsoleRight = -1; $tvConsoleBottom = -1
for ($y = 0; $y -lt $tvConsoleSource.Height; $y++) {
    for ($x = 0; $x -lt $tvConsoleSource.Width; $x++) {
        $tvConsoleColor = $tvConsoleSource.GetPixel($x, $y)
        if ($tvConsoleColor.A -ge 128) {
            $tvConsoleSource.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $tvConsoleColor.R, $tvConsoleColor.G, $tvConsoleColor.B))
            $tvConsoleLeft = [Math]::Min($tvConsoleLeft, $x); $tvConsoleTop = [Math]::Min($tvConsoleTop, $y)
            $tvConsoleRight = [Math]::Max($tvConsoleRight, $x); $tvConsoleBottom = [Math]::Max($tvConsoleBottom, $y)
        } else { $tvConsoleSource.SetPixel($x, $y, [System.Drawing.Color]::Transparent) }
    }
}
if ($tvConsoleRight -lt 0) { throw 'No opaque table found.' }
$tvConsoleBounds = [System.Drawing.Rectangle]::new($tvConsoleLeft, $tvConsoleTop, $tvConsoleRight - $tvConsoleLeft + 1, $tvConsoleBottom - $tvConsoleTop + 1)
$tvConsoleScale = [Math]::Min(744.0 / $tvConsoleBounds.Width, 168.0 / $tvConsoleBounds.Height)
$tvConsoleWidth = [int][Math]::Round($tvConsoleBounds.Width * $tvConsoleScale)
$tvConsoleHeight = [int][Math]::Round($tvConsoleBounds.Height * $tvConsoleScale)
$tvConsoleDestination = [System.Drawing.Rectangle]::new([int][Math]::Floor((768 - $tvConsoleWidth) / 2), [int][Math]::Floor((192 - $tvConsoleHeight) / 2), $tvConsoleWidth, $tvConsoleHeight)
$tvConsoleOutput = [System.Drawing.Bitmap]::new(768, 192, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$tvConsoleGraphics = [System.Drawing.Graphics]::FromImage($tvConsoleOutput)
$tvConsoleGraphics.Clear([System.Drawing.Color]::Transparent)
$tvConsoleGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$tvConsoleGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$tvConsoleGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$tvConsoleGraphics.DrawImage($tvConsoleSource, $tvConsoleDestination, $tvConsoleBounds, [System.Drawing.GraphicsUnit]::Pixel)
$tvConsoleOutput.Save($tvConsoleTarget, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved: $tvConsoleTarget; canvas=768x192; table=$($tvConsoleWidth)x$($tvConsoleHeight); alpha=$($tvConsoleOutput.GetPixel(0,0).A); source bounds=$tvConsoleBounds"
$tvConsoleGraphics.Dispose(); $tvConsoleOutput.Dispose(); $tvConsoleSource.Dispose()
