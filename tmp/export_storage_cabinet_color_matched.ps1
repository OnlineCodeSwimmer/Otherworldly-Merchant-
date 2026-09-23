Add-Type -AssemblyName System.Drawing
$cabinetJobs = @(
    @{ Source = 'exec-2eb068d6-a1a7-4021-8e1c-f31c89fadb66.png'; Reference = 'Assets\AIGC Source\Building\Object\storage_cabinet_topdown_512x512.png'; PixelScale = 1; Existing = 'Assets\AIGC Source\Building\Object\storage_cabinet_damaged_topdown_512x512.png'; Target = 'Assets\AIGC Source\Building\Object\storage_cabinet_damaged_topdown_color_matched_v2_512x512.png'; Sample = @(225,235,48,30) },
    @{ Source = 'exec-30a31985-a350-4267-8f18-03e5796f9bdc.png'; Reference = 'Assets\AIGC Source\Building\Object\Front Image\storage_cabinet_single_door_front_512x512.png'; PixelScale = 4; Existing = 'Assets\AIGC Source\Building\Object\Front Image\storage_cabinet_single_door_damaged_front_512x512.png'; Target = 'Assets\AIGC Source\Building\Object\Front Image\storage_cabinet_single_door_damaged_front_color_matched_v2_512x512.png'; Sample = @(180,120,100,240) }
)
foreach ($cabinetJob in $cabinetJobs) {
    $referencePath = Join-Path (Get-Location) $cabinetJob.Reference
    $existingPath = Join-Path (Get-Location) $cabinetJob.Existing
    $targetPath = Join-Path (Get-Location) $cabinetJob.Target
    if ((Test-Path -LiteralPath $targetPath) -or (Test-Path -LiteralPath ($targetPath + '.meta'))) { throw "Refusing to overwrite: $targetPath" }
    $referenceHash = (Get-FileHash -LiteralPath $referencePath).Hash
    $existingHash = (Get-FileHash -LiteralPath $existingPath).Hash
    $referenceBitmap = [System.Drawing.Bitmap]::new($referencePath)
    $refLeft = 512; $refTop = 512; $refRight = -1; $refBottom = -1
    for ($y = 0; $y -lt 512; $y++) {
        for ($x = 0; $x -lt 512; $x++) {
            if ($referenceBitmap.GetPixel($x, $y).A -ge 128) {
                $refLeft = [Math]::Min($refLeft, $x); $refTop = [Math]::Min($refTop, $y)
                $refRight = [Math]::Max($refRight, $x); $refBottom = [Math]::Max($refBottom, $y)
            }
        }
    }
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
    if ($right -lt 0 -or $refRight -lt 0) { throw 'No cabinet pixels found.' }
    $bounds = [System.Drawing.Rectangle]::new($left, $top, $right-$left+1, $bottom-$top+1)
    $logicalSize = [int](512 / $cabinetJob.PixelScale)
    $destination = [System.Drawing.Rectangle]::new([int][Math]::Round($refLeft/$cabinetJob.PixelScale), [int][Math]::Round($refTop/$cabinetJob.PixelScale), [int][Math]::Round(($refRight-$refLeft+1)/$cabinetJob.PixelScale), [int][Math]::Round(($refBottom-$refTop+1)/$cabinetJob.PixelScale))
    $logicalBitmap = [System.Drawing.Bitmap]::new($logicalSize, $logicalSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $logicalGraphics = [System.Drawing.Graphics]::FromImage($logicalBitmap)
    $logicalGraphics.Clear([System.Drawing.Color]::Transparent)
    $logicalGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $logicalGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $logicalGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $logicalGraphics.DrawImage($sourceBitmap, $destination, $bounds, [System.Drawing.GraphicsUnit]::Pixel)
    $outputBitmap = [System.Drawing.Bitmap]::new(512,512,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $outputGraphics = [System.Drawing.Graphics]::FromImage($outputBitmap)
    $outputGraphics.Clear([System.Drawing.Color]::Transparent)
    $outputGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $outputGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $outputGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $outputGraphics.DrawImage($logicalBitmap,[System.Drawing.Rectangle]::new(0,0,512,512),[System.Drawing.Rectangle]::new(0,0,$logicalSize,$logicalSize),[System.Drawing.GraphicsUnit]::Pixel)
    $outputBitmap.Save($targetPath,[System.Drawing.Imaging.ImageFormat]::Png)
    $meta = Get-Content -Raw -Encoding UTF8 -LiteralPath ($existingPath + '.meta')
    $meta = $meta -replace '(?m)^guid: [0-9a-f]+', ('guid: ' + [Guid]::NewGuid().ToString('N'))
    $meta = $meta -replace '(?m)^(\s*spriteID:) [0-9a-f]+', ('$1 ' + [Guid]::NewGuid().ToString('N'))
    [System.IO.File]::WriteAllText(($targetPath+'.meta'),$meta,[System.Text.UTF8Encoding]::new($false))
    $sum = 0; $count = 0; $colors = @{}
    $region = $cabinetJob.Sample
    for ($y=$region[1]; $y -lt ($region[1]+$region[3]); $y++) {
        for ($x=$region[0]; $x -lt ($region[0]+$region[2]); $x++) {
            $pixel = $outputBitmap.GetPixel($x,$y)
            if ($pixel.A -lt 128) { continue }
            $sum += ($pixel.R+$pixel.G+$pixel.B)/3; $count++
            $key = '{0:X2}{1:X2}{2:X2}' -f $pixel.R,$pixel.G,$pixel.B
            if (!$colors.ContainsKey($key)) { $colors[$key]=0 }; $colors[$key]++
        }
    }
    Write-Output "Saved: $targetPath; canvas=512x512; cornerAlpha=$($outputBitmap.GetPixel(0,0).A); sampleMean=$([Math]::Round($sum/$count,2)); sampleColors=$($colors.Count)"
    $colors.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 5 | Format-Table -HideTableHeaders
    $outputGraphics.Dispose(); $logicalGraphics.Dispose(); $outputBitmap.Dispose(); $logicalBitmap.Dispose(); $sourceBitmap.Dispose(); $referenceBitmap.Dispose()
    if ((Get-FileHash -LiteralPath $referencePath).Hash -ne $referenceHash -or (Get-FileHash -LiteralPath $existingPath).Hash -ne $existingHash) { throw 'Existing sprite unexpectedly changed.' }
}
