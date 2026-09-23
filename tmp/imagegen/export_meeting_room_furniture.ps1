$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$outputFolder = Join-Path (Get-Location) 'Assets\AIGC Source\Building\Object\Meeting Room'
New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null

function Prepare-Sprite([string]$sourcePath,[string]$baseName,[object[]]$sizes) {
    $input=[System.Drawing.Bitmap]::FromFile($sourcePath)
    $clean=[System.Drawing.Bitmap]::new($input.Width,$input.Height,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $minX=$input.Width; $minY=$input.Height; $maxX=-1; $maxY=-1
    for($y=0;$y -lt $input.Height;$y++) {
        for($x=0;$x -lt $input.Width;$x++) {
            $color=$input.GetPixel($x,$y)
            if($color.A -ge 128) {
                $clean.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,$color.R,$color.G,$color.B))
                if($x -lt $minX){$minX=$x}; if($x -gt $maxX){$maxX=$x}
                if($y -lt $minY){$minY=$y}; if($y -gt $maxY){$maxY=$y}
            } else {
                $clean.SetPixel($x,$y,[System.Drawing.Color]::Transparent)
            }
        }
    }
    $input.Dispose()
    if($maxX -lt 0){$clean.Dispose();throw "No visible pixels: $baseName"}
    $cropWidth=$maxX-$minX+1; $cropHeight=$maxY-$minY+1
    $fullPadding=12
    $full=[System.Drawing.Bitmap]::new($cropWidth+2*$fullPadding,$cropHeight+2*$fullPadding,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $fg=[System.Drawing.Graphics]::FromImage($full)
    $fg.Clear([System.Drawing.Color]::Transparent)
    $fg.CompositingMode=[System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $fg.DrawImage($clean,[System.Drawing.Rectangle]::new($fullPadding,$fullPadding,$cropWidth,$cropHeight),[System.Drawing.Rectangle]::new($minX,$minY,$cropWidth,$cropHeight),[System.Drawing.GraphicsUnit]::Pixel)
    $fg.Dispose()
    $fullPath=Join-Path $outputFolder ($baseName+'_fullres.png')
    if(Test-Path -LiteralPath $fullPath){throw "Output exists: $fullPath"}
    $full.Save($fullPath,[System.Drawing.Imaging.ImageFormat]::Png)
    foreach($size in $sizes) {
        $targetWidth=[int]$size[0]; $targetHeight=[int]$size[1]; $padding=[int]$size[2]
        $path=Join-Path $outputFolder ($baseName+'_'+$targetWidth+'x'+$targetHeight+'.png')
        if(Test-Path -LiteralPath $path){throw "Output exists: $path"}
        $availableWidth=$targetWidth-2*$padding; $availableHeight=$targetHeight-2*$padding
        $scale=[Math]::Min($availableWidth/$cropWidth,$availableHeight/$cropHeight)
        $drawWidth=[Math]::Max(1,[int][Math]::Round($cropWidth*$scale)); $drawHeight=[Math]::Max(1,[int][Math]::Round($cropHeight*$scale))
        $target=[System.Drawing.Bitmap]::new($targetWidth,$targetHeight,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics=[System.Drawing.Graphics]::FromImage($target)
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.CompositingMode=[System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        $graphics.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
        $graphics.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
        $graphics.DrawImage($clean,[System.Drawing.Rectangle]::new([int](($targetWidth-$drawWidth)/2),[int](($targetHeight-$drawHeight)/2),$drawWidth,$drawHeight),[System.Drawing.Rectangle]::new($minX,$minY,$cropWidth,$cropHeight),[System.Drawing.GraphicsUnit]::Pixel)
        $graphics.Dispose()
        $target.Save($path,[System.Drawing.Imaging.ImageFormat]::Png)
        Write-Output "$baseName -> ${targetWidth}x${targetHeight}, object ${drawWidth}x${drawHeight}, corner alpha=$($target.GetPixel(0,0).A)"
        $target.Dispose()
    }
    $full.Dispose();$clean.Dispose()
}

Prepare-Sprite 'C:\Users\望兴腾\.codex\generated_images\019f896a-5eb7-7d33-9f82-498fb98a05c0\exec-22bffb58-9bc3-4684-9cb2-4badca9befee.png' 'meeting_table_modern_topdown' @(@(128,384,4),@(256,768,8))
Prepare-Sprite 'C:\Users\望兴腾\.codex\generated_images\019f896a-5eb7-7d33-9f82-498fb98a05c0\exec-6b898c26-d4bc-4d43-9c3f-457655d45ee1.png' 'meeting_chair_taupe_topdown' @(@(64,64,4),@(128,128,8))
