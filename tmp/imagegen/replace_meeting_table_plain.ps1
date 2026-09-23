$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$sourcePath='C:\Users\望兴腾\.codex\generated_images\019f896a-5eb7-7d33-9f82-498fb98a05c0\exec-cc64c2ee-9944-4f78-bd50-5396fc5c1423.png'
$folder=(Resolve-Path -LiteralPath 'Assets\AIGC Source\Building\Object\Meeting Room').Path
$targets=@(
    @{Name='meeting_table_modern_topdown_fullres.png';Width=449;Height=1312;Padding=12},
    @{Name='meeting_table_modern_topdown_128x384.png';Width=128;Height=384;Padding=4},
    @{Name='meeting_table_modern_topdown_256x768.png';Width=256;Height=768;Padding=8}
)
foreach($target in $targets){
    $targetPath=[System.IO.Path]::GetFullPath((Join-Path $folder $target.Name))
    if(-not $targetPath.StartsWith($folder+'\')){throw 'Target outside Meeting Room folder.'}
    if(-not (Test-Path -LiteralPath $targetPath)){throw "Missing target: $targetPath"}
}

$input=[System.Drawing.Bitmap]::FromFile($sourcePath)
$clean=[System.Drawing.Bitmap]::new($input.Width,$input.Height,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$minX=$input.Width;$minY=$input.Height;$maxX=-1;$maxY=-1
for($y=0;$y -lt $input.Height;$y++){
    for($x=0;$x -lt $input.Width;$x++){
        $color=$input.GetPixel($x,$y)
        if($color.A -ge 128){
            $clean.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,$color.R,$color.G,$color.B))
            if($x -lt $minX){$minX=$x};if($x -gt $maxX){$maxX=$x}
            if($y -lt $minY){$minY=$y};if($y -gt $maxY){$maxY=$y}
        } else {$clean.SetPixel($x,$y,[System.Drawing.Color]::Transparent)}
    }
}
$input.Dispose()
$cropWidth=$maxX-$minX+1;$cropHeight=$maxY-$minY+1
foreach($target in $targets){
    $availableWidth=$target.Width-2*$target.Padding;$availableHeight=$target.Height-2*$target.Padding
    $scale=[Math]::Min($availableWidth/$cropWidth,$availableHeight/$cropHeight)
    $drawWidth=[Math]::Max(1,[int][Math]::Round($cropWidth*$scale));$drawHeight=[Math]::Max(1,[int][Math]::Round($cropHeight*$scale))
    $bitmap=[System.Drawing.Bitmap]::new($target.Width,$target.Height,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics=[System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.CompositingMode=[System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $graphics.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $graphics.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $graphics.DrawImage($clean,[System.Drawing.Rectangle]::new([int](($target.Width-$drawWidth)/2),[int](($target.Height-$drawHeight)/2),$drawWidth,$drawHeight),[System.Drawing.Rectangle]::new($minX,$minY,$cropWidth,$cropHeight),[System.Drawing.GraphicsUnit]::Pixel)
    $graphics.Dispose()
    $targetPath=Join-Path $folder $target.Name
    $bitmap.Save($targetPath,[System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output "$($target.Name): $($bitmap.Width)x$($bitmap.Height), corner alpha=$($bitmap.GetPixel(0,0).A)"
    $bitmap.Dispose()
}
$clean.Dispose()
