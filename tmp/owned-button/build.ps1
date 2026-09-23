$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=(Get-Location).Path
$dir=Join-Path $root 'tmp/owned-button'
$gen=[System.Drawing.Bitmap]::FromFile('C:/Users/望兴腾/.codex/generated_images/01a03835-304f-7671-84b2-f0cb8dbe18d1/exec-9633140b-ba0b-46f6-a11d-c23d2e52e086.png')
$normal=[System.Drawing.Bitmap]::FromFile((Join-Path $root 'Assets/AIGC Source/UI/Shop/win98_category_button_normal_160x48.png'))
$button=[System.Drawing.Bitmap]::new(160,48,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$levels=@(132,168,192,210,236,248)
for($y=0;$y -lt 48;$y++){
    for($x=0;$x -lt 160;$x++){
        $sx=[int][math]::Floor(($x+0.5)*$gen.Width/160)
        $sy=[int][math]::Floor(($y+0.5)*$gen.Height/48)
        $p=$gen.GetPixel($sx,$sy);$gray=($p.R+$p.G+$p.B)/3
        $nearest=$levels[0];$distance=999
        foreach($v in $levels){if([math]::Abs($gray-$v) -lt $distance){$nearest=$v;$distance=[math]::Abs($gray-$v)}}
        # Flatten texture/noise in the generated fill while retaining its inset edge.
        if($x -ge 3 -and $x -le 156 -and $y -ge 3 -and $y -le 44){$nearest=210}
        $button.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,$nearest,$nearest,$nearest))
    }
}
$button.Save((Join-Path $dir 'win98_button_owned_disabled_160x48.png'),[System.Drawing.Imaging.ImageFormat]::Png)

# Use the user's existing OWNED lettering only in the preview. The actual sprite is blank.
$capture=[System.Drawing.Bitmap]::FromFile('C:/Users/望兴腾/AppData/Local/Temp/codex-clipboard-d0ff4898-98c4-4e22-96fe-57d75b3abaa2.png')
$glyph=[System.Drawing.Bitmap]::new(40,9,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
for($y=0;$y -lt 9;$y++){for($x=0;$x -lt 40;$x++){$p=$capture.GetPixel(20+$x,21+$y);if(($p.R+$p.G+$p.B)/3 -lt 185){$glyph.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,132,132,132))}}}
$labeled=[System.Drawing.Bitmap]::new($button)
$lg=[System.Drawing.Graphics]::FromImage($labeled)
$lg.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$lg.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
$shadow=[System.Drawing.Bitmap]::new($glyph)
for($y=0;$y -lt 9;$y++){for($x=0;$x -lt 40;$x++){if($shadow.GetPixel($x,$y).A -gt 0){$shadow.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,239,239,239))}}}
$lg.DrawImage($shadow,[System.Drawing.Rectangle]::new(22,13,120,27))
$lg.DrawImage($glyph,[System.Drawing.Rectangle]::new(20,11,120,27))
$lg.Dispose()
$labeled.Save((Join-Path $dir 'owned-labeled-preview.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$preview=[System.Drawing.Bitmap]::new(640,264)
$g=[System.Drawing.Graphics]::FromImage($preview)
$g.Clear([System.Drawing.Color]::FromArgb(228,228,228))
$g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
$font=[System.Drawing.Font]::new('Arial',13)
$g.DrawString('OWNED / DISABLED',$font,[System.Drawing.Brushes]::DimGray,36,18)
$g.DrawImage($labeled,[System.Drawing.Rectangle]::new(80,58,480,144))
$g.DrawImage($labeled,[System.Drawing.Rectangle]::new(293,224,54,18))
$preview.Save((Join-Path $dir 'owned-disabled-preview.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose();$preview.Dispose();$font.Dispose();$labeled.Dispose();$glyph.Dispose();$shadow.Dispose();$capture.Dispose();$gen.Dispose();$normal.Dispose();$button.Dispose()
Write-Output 'Created 160x48 blank inset sprite and separate OWNED preview.'
