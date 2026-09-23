Add-Type -AssemblyName System.Drawing
$originalPath = 'C:\Users\望兴腾\.codex\generated_images\01a0ad86-844a-7e50-9b5e-4843c923a4c1\exec-5f0d0ca8-7ddd-407c-a461-d0a03ec90020.png'
$editedPath = 'C:\Users\望兴腾\.codex\generated_images\01a0ad86-844a-7e50-9b5e-4843c923a4c1\exec-bac987e9-e123-42d6-935d-80fbc54094a8.png'
$original = [System.Drawing.Bitmap]::new($originalPath)
$edited = [System.Drawing.Bitmap]::new($editedPath)
if ($original.Size -ne $edited.Size) { throw 'Edited canvas differs from original; cannot preserve placement.' }
$left = $original.Width; $top = $original.Height; $right = -1; $bottom = -1
for ($y = 0; $y -lt $original.Height; $y++) {
    for ($x = 0; $x -lt $original.Width; $x++) {
        if ($original.GetPixel($x, $y).A -ge 128) {
            $left = [Math]::Min($left, $x); $top = [Math]::Min($top, $y)
            $right = [Math]::Max($right, $x); $bottom = [Math]::Max($bottom, $y)
        }
        $pixel = $edited.GetPixel($x, $y)
        if ($pixel.A -ge 128) {
            $edited.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $pixel.R, $pixel.G, $pixel.B))
        } else { $edited.SetPixel($x, $y, [System.Drawing.Color]::Transparent) }
    }
}
$sourceRectangle = [System.Drawing.Rectangle]::new($left, $top, $right - $left + 1, $bottom - $top + 1)
$output = [System.Drawing.Bitmap]::new(288, 160, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($output)
$graphics.Clear([System.Drawing.Color]::Transparent)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$scale = [Math]::Min(280.0 / $sourceRectangle.Width, 152.0 / $sourceRectangle.Height)
$width = [int][Math]::Round($sourceRectangle.Width * $scale)
$height = [int][Math]::Round($sourceRectangle.Height * $scale)
$destination = [System.Drawing.Rectangle]::new([int][Math]::Floor((288 - $width) / 2), [int][Math]::Floor((160 - $height) / 2), $width, $height)
$graphics.DrawImage($edited, $destination, $sourceRectangle, [System.Drawing.GraphicsUnit]::Pixel)
$target = Join-Path (Get-Location) 'Assets\AIGC Source\Building\Object\clinic_staircase_wide_topdown_288x160.png'
$metaHashBefore = (Get-FileHash -LiteralPath ($target + '.meta')).Hash
$backupDirectory = Join-Path (Get-Location) 'tmp\imagegen'
New-Item -ItemType Directory -Path $backupDirectory -Force | Out-Null
$backup = Join-Path $backupDirectory ('clinic_staircase_before_no_sides_' + [Guid]::NewGuid().ToString('N') + '.png')
Copy-Item -LiteralPath $target -Destination $backup
$output.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
if ((Get-FileHash -LiteralPath ($target + '.meta')).Hash -ne $metaHashBefore) { throw 'Unity metadata changed unexpectedly.' }
Write-Output "Updated $target; canvas=288x160; original framing retained; Unity metadata unchanged. Backup: $backup"
$graphics.Dispose(); $output.Dispose(); $edited.Dispose(); $original.Dispose()
