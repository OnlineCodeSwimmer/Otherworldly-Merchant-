$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$sourcePath = 'C:\Users\望兴腾\.codex\generated_images\019f896a-5eb7-7d33-9f82-498fb98a05c0\exec-2ee32f2c-6cce-490e-a58a-f6a314bb407d.png'
$outputFolder = Join-Path (Get-Location) 'Assets\AIGC Source\Inventory Item'
$sourceOutput = Join-Path $outputFolder 'cpu_common_v2_source.png'
$icon128Output = Join-Path $outputFolder 'cpu_common_v2_128x128.png'
$icon64Output = Join-Path $outputFolder 'cpu_common_v2_64x64.png'
foreach ($path in @($sourceOutput,$icon128Output,$icon64Output)) {
    if (Test-Path -LiteralPath $path) { throw "Output already exists: $path" }
}

$input = [System.Drawing.Bitmap]::FromFile($sourcePath)
$clean = [System.Drawing.Bitmap]::new($input.Width,$input.Height,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$minX=$input.Width; $minY=$input.Height; $maxX=-1; $maxY=-1
for ($y=0; $y -lt $input.Height; $y++) {
    for ($x=0; $x -lt $input.Width; $x++) {
        $color=$input.GetPixel($x,$y)
        if ($color.R -gt ($color.G+35) -and $color.B -gt ($color.G+35)) {
            $clean.SetPixel($x,$y,[System.Drawing.Color]::Transparent)
        } else {
            $clean.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,$color.R,$color.G,$color.B))
            if($x -lt $minX){$minX=$x}; if($x -gt $maxX){$maxX=$x}
            if($y -lt $minY){$minY=$y}; if($y -gt $maxY){$maxY=$y}
        }
    }
}
$input.Dispose()
if($maxX -lt 0){throw 'No CPU pixels found.'}
$clean.Save($sourceOutput,[System.Drawing.Imaging.ImageFormat]::Png)

function Export-Icon([int]$size,[string]$path) {
    $padding=if($size -eq 128){8}else{4}
    $available=$size-2*$padding
    $cropWidth=$maxX-$minX+1; $cropHeight=$maxY-$minY+1
    $scale=[Math]::Min($available/$cropWidth,$available/$cropHeight)
    $drawWidth=[int][Math]::Round($cropWidth*$scale); $drawHeight=[int][Math]::Round($cropHeight*$scale)
    $icon=[System.Drawing.Bitmap]::new($size,$size,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics=[System.Drawing.Graphics]::FromImage($icon)
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.CompositingMode=[System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $graphics.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $graphics.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $graphics.DrawImage($clean,[System.Drawing.Rectangle]::new([int](($size-$drawWidth)/2),[int](($size-$drawHeight)/2),$drawWidth,$drawHeight),[System.Drawing.Rectangle]::new($minX,$minY,$cropWidth,$cropHeight),[System.Drawing.GraphicsUnit]::Pixel)
    $graphics.Dispose()
    $icon.Save($path,[System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output "${size}x${size}, object ${drawWidth}x${drawHeight}, corner alpha=$($icon.GetPixel(0,0).A)"
    $icon.Dispose()
}
Export-Icon 128 $icon128Output
Export-Icon 64 $icon64Output
$clean.Dispose()
