$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$sourcePath = 'C:\Users\望兴腾\.codex\generated_images\01a0e2f9-6c16-77e3-93cb-9192d84247fe\exec-cea3aece-4ce7-4f5b-bb87-4b36980cb113.png'
$outDir = 'C:\Users\望兴腾\.codex\visualizations\2026\09\27\01a0e2f9-6c16-77e3-93cb-9192d84247fe'
$source = [System.Drawing.Bitmap]::new($sourcePath)
$edited = $source.Clone([System.Drawing.Rectangle]::new(0,0,2172,724),[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$changed = 0
for ($frame = 0; $frame -lt 4; $frame++) {
    foreach ($range in @(@(110,224), @(320,434))) {
        for ($y = 420; $y -lt 724; $y++) {
            for ($x = $range[0]; $x -lt $range[1]; $x++) {
                $px = $frame*543+$x
                if ($y+74 -lt 724) { $color=$source.GetPixel($px,$y+74) }
                else { $color=[System.Drawing.Color]::Transparent }
                $edited.SetPixel($px,$y,$color)
            }
        }
    }
}
# Verify that only the selected forearm/hand rectangles changed.
for ($y=0; $y -lt 724; $y++) {
    for ($x=0; $x -lt 2172; $x++) {
        if ($source.GetPixel($x,$y).ToArgb() -ne $edited.GetPixel($x,$y).ToArgb()) {
            $localX=$x%543
            if ($y -lt 420 -or -not (($localX -ge 110 -and $localX -lt 224) -or ($localX -ge 320 -and $localX -lt 434))) { throw 'Pixels outside arms changed' }
            $changed++
        }
    }
}
$edited.Save((Join-Path $outDir 'silencer_run_original_style_short.png'),[System.Drawing.Imaging.ImageFormat]::Png)
# Preserve source pixels at 1:1. The crop is identical to the previous importer.
$sheet=[System.Drawing.Bitmap]::new(2072,518,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
for ($frame=0; $frame -lt 4; $frame++) {
    for ($y=0; $y -lt 518; $y++) {
        for ($x=0; $x -lt 518; $x++) {
            $sheet.SetPixel($frame*518+$x,$y,$edited.GetPixel($frame*543+12+$x,129+$y))
        }
    }
}
$sheet.Save((Join-Path $outDir 'silencer_run_original_style_unity.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$preview=[System.Drawing.Bitmap]::new(2072,518)
$g=[System.Drawing.Graphics]::FromImage($preview)
$g.Clear([System.Drawing.Color]::FromArgb(232,232,232))
$g.DrawImageUnscaled($sheet,0,0)
$preview.Save((Join-Path $outDir 'silencer_run_original_style_preview.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$preview.Dispose()
$sheet.Dispose()
$source.Dispose()
$edited.Dispose()
Write-Output "Shortened only forearms by 74 source pixels; checked $changed changed pixels; all pixels outside arm rectangles preserved. Export 2072x518, four 518x518 cells."
