Add-Type -AssemblyName System.Drawing
$stairSource = [System.Drawing.Bitmap]::new('C:\Users\望兴腾\.codex\generated_images\01a0ae4a-d442-7940-b14a-26c7fe151872\exec-449d2c8d-5a9c-40a4-92b0-527301fe5104.png')
$left = $stairSource.Width; $top = $stairSource.Height; $right = -1; $bottom = -1
for ($y = 0; $y -lt $stairSource.Height; $y++) {
    for ($x = 0; $x -lt $stairSource.Width; $x++) {
        $color = $stairSource.GetPixel($x, $y)
        if ($color.A -ge 128) {
            $stairSource.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $color.R, $color.G, $color.B))
            $left = [Math]::Min($left, $x); $top = [Math]::Min($top, $y)
            $right = [Math]::Max($right, $x); $bottom = [Math]::Max($bottom, $y)
        } else { $stairSource.SetPixel($x, $y, [System.Drawing.Color]::Transparent) }
    }
}
if ($right -lt 0) { throw 'No opaque microwave pixels found.' }
$bounds = [System.Drawing.Rectangle]::new($left, $top, $right - $left + 1, $bottom - $top + 1)
$stairOutput = [System.Drawing.Bitmap]::new(64, 64, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($stairOutput)
$graphics.Clear([System.Drawing.Color]::Transparent)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$scale = [Math]::Min(56.0 / $bounds.Width, 56.0 / $bounds.Height)
$width = [int][Math]::Round($bounds.Width * $scale)
$height = [int][Math]::Round($bounds.Height * $scale)
$destination = [System.Drawing.Rectangle]::new([int][Math]::Floor((64 - $width) / 2), [int][Math]::Floor((64 - $height) / 2), $width, $height)
$graphics.DrawImage($stairSource, $destination, $bounds, [System.Drawing.GraphicsUnit]::Pixel)
$target = Join-Path (Get-Location) 'Assets\AIGC Source\Building\Object\Office\office_microwave_topdown_64x64.png'
if (-not (Test-Path -LiteralPath $target)) { throw "Expected existing microwave asset: $target" }
$metaTarget = "$target.meta"
$metaHashBefore = (Get-FileHash -LiteralPath $metaTarget -Algorithm SHA256).Hash
$backupDirectory = Join-Path (Get-Location) 'tmp\imagegen'
New-Item -ItemType Directory -Path $backupDirectory -Force | Out-Null
$backupTarget = Join-Path $backupDirectory ("office_microwave_before_handle_" + [guid]::NewGuid().ToString('N') + '.png')
Copy-Item -LiteralPath $target -Destination $backupTarget -ErrorAction Stop
if ((Get-FileHash -LiteralPath $target).Hash -ne (Get-FileHash -LiteralPath $backupTarget).Hash) { throw 'Backup verification failed.' }
$stairOutput.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved: $target; canvas=64x64; object=$($width)x$($height); cornerAlpha=$($stairOutput.GetPixel(0,0).A)"
$graphics.Dispose(); $stairOutput.Dispose(); $stairSource.Dispose()
if ((Get-FileHash -LiteralPath $metaTarget -Algorithm SHA256).Hash -ne $metaHashBefore) { throw 'Unity metadata changed unexpectedly.' }
Write-Output "Backup: $backupTarget"
Write-Output "Unity metadata and GUID unchanged: $metaHashBefore"
