param([string]$CommitRunDirectory)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$cabinetWorkspace = [System.IO.Path]::GetFullPath((Get-Location).Path)
$cabinetBackupRoot = Join-Path $cabinetWorkspace 'tmp\imagegen\cabinet_exact_palette'
$cabinetJobs = @(
    @{ View='topdown'; Reference='Assets\AIGC Source\Building\Object\storage_cabinet_topdown_512x512.png'; Target='Assets\AIGC Source\Building\Object\storage_cabinet_damaged_topdown_512x512.png'; Sample=@(225,235,27,30) },
    @{ View='front'; Reference='Assets\AIGC Source\Building\Object\Front Image\storage_cabinet_single_door_front_512x512.png'; Target='Assets\AIGC Source\Building\Object\Front Image\storage_cabinet_single_door_damaged_front_512x512.png'; Sample=@(180,120,60,240) }
)
function Assert-CabinetWorkspacePath([string]$path) {
    $absolute = [System.IO.Path]::GetFullPath($path)
    if (!$absolute.StartsWith($cabinetWorkspace+'\',[System.StringComparison]::OrdinalIgnoreCase)) { throw "Outside workspace: $absolute" }
    return $absolute
}
if ($CommitRunDirectory) {
    $runDirectory = Assert-CabinetWorkspacePath $CommitRunDirectory
    if (!$runDirectory.StartsWith($cabinetBackupRoot+'\',[System.StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid palette run directory.' }
    $audit = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $runDirectory 'audit.json') | ConvertFrom-Json
    foreach ($record in $audit) {
        $job = $cabinetJobs | Where-Object { $_.View -eq $record.View }
        if (!$job -or $record.Target -ne $job.Target -or $record.Reference -ne $job.Reference) { throw 'Unexpected asset target.' }
        foreach ($check in @(@{Path=$record.Target;Hash=$record.TargetHash},@{Path=($record.Target+'.meta');Hash=$record.MetaHash},@{Path=$record.Reference;Hash=$record.ReferenceHash})) {
            $path = Assert-CabinetWorkspacePath (Join-Path $cabinetWorkspace $check.Path)
            if ((Get-FileHash -LiteralPath $path).Hash -ne $check.Hash) { throw "Asset changed after staging: $path" }
        }
        if ((Get-FileHash -LiteralPath (Join-Path $runDirectory ($record.View+'_before.png'))).Hash -ne $record.TargetHash) { throw 'Invalid original backup.' }
        if ((Get-FileHash -LiteralPath (Join-Path $runDirectory ($record.View+'_corrected.png'))).Hash -ne $record.CorrectedHash) { throw 'Invalid staged output.' }
    }
    foreach ($record in $audit) {
        $targetPath = Assert-CabinetWorkspacePath (Join-Path $cabinetWorkspace $record.Target)
        Copy-Item -LiteralPath (Join-Path $runDirectory ($record.View+'_corrected.png')) -Destination $targetPath -Force
        if ((Get-FileHash -LiteralPath $targetPath).Hash -ne $record.CorrectedHash) { throw 'Asset replacement failed.' }
        if ((Get-FileHash -LiteralPath ($targetPath+'.meta')).Hash -ne $record.MetaHash) { throw 'Unity metadata changed.' }
        if ((Get-FileHash -LiteralPath (Join-Path $cabinetWorkspace $record.Reference)).Hash -ne $record.ReferenceHash) { throw 'Intact cabinet changed.' }
        Write-Output "Replaced: $targetPath; original GUID and import settings retained."
    }
    Write-Output "Backup directory: $runDirectory"
    return
}
$runDirectory = Join-Path $cabinetBackupRoot ([Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $runDirectory -Force | Out-Null
$auditRecords = @()
foreach ($job in $cabinetJobs) {
    $referencePath = Assert-CabinetWorkspacePath (Join-Path $cabinetWorkspace $job.Reference)
    $targetPath = Assert-CabinetWorkspacePath (Join-Path $cabinetWorkspace $job.Target)
    $beforeHash = (Get-FileHash -LiteralPath $targetPath).Hash
    $referenceHash = (Get-FileHash -LiteralPath $referencePath).Hash
    $metaHash = (Get-FileHash -LiteralPath ($targetPath+'.meta')).Hash
    Copy-Item -LiteralPath $targetPath -Destination (Join-Path $runDirectory ($job.View+'_before.png'))
    Copy-Item -LiteralPath ($targetPath+'.meta') -Destination (Join-Path $runDirectory ($job.View+'_before.png.meta'))
    $reference = [System.Drawing.Bitmap]::new($referencePath)
    $before = [System.Drawing.Bitmap]::new($targetPath)
    if ($before.Width -ne 512 -or $before.Height -ne 512 -or $reference.Width -ne 512 -or $reference.Height -ne 512) { throw 'Unexpected canvas dimensions.' }
    $corrected = $before.Clone([System.Drawing.Rectangle]::new(0,0,512,512),[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $changed = 0; $protected = 0; $verifiedPaint = 0
    for ($y=0; $y -lt 512; $y++) {
        for ($x=0; $x -lt 512; $x++) {
            $pixel = $before.GetPixel($x,$y)
            if ($pixel.A -eq 0) { continue }
            $luminance = ($pixel.R+$pixel.G+$pixel.B)/3.0
            $preserve = $false
            $sampleX = $x; $sampleY = $y
            if ($job.View -eq 'topdown') {
                # Preserve all exposed-metal hardware and the dark/light features of the existing damage.
                $damageZone = $x -ge 252 -and $y -ge 235
                $preserve = ($y -ge 289) -or ($damageZone -and ($luminance -lt 54 -or $luminance -gt 76))
                if ($damageZone -and !$preserve -and $x -ge 215 -and $x -le 295 -and $y -ge 226 -and $y -le 284) {
                    $sampleX = [Math]::Min(291,[Math]::Max(219,$x))
                    $sampleY = [Math]::Min(279,[Math]::Max(229,$y))
                }
            } else {
                $damageZone = $x -ge 252 -and $y -le 259
                $handleZone = $x -ge 308 -and $x -le 351 -and $y -ge 216 -and $y -le 327
                $preserve = ($damageZone -and ($luminance -lt 60 -or $luminance -gt 70)) -or ($handleZone -and ($luminance -lt 40 -or $luminance -gt 85))
                if (($damageZone -or $handleZone) -and !$preserve -and $x -ge 168 -and $x -le 343 -and $y -ge 56 -and $y -le 457) {
                    # Never stamp the intact handle at its old position; sample only original painted door pixels.
                    $sampleX = [Math]::Min(312,[Math]::Max(176,$x))
                    $sampleY = [Math]::Min(448,[Math]::Max(64,$y))
                }
            }
            if ($preserve) { $protected++; continue }
            $paint = $reference.GetPixel($sampleX,$sampleY)
            if ($paint.A -eq 0) { continue }
            $replacement = [System.Drawing.Color]::FromArgb($pixel.A,$paint.R,$paint.G,$paint.B)
            $corrected.SetPixel($x,$y,$replacement)
            $verifiedPaint++
            if ($replacement.ToArgb() -ne $pixel.ToArgb()) { $changed++ }
        }
    }
    $alphaChanges = 0; $sampleMismatch = 0; $refSampleSum = 0; $outSampleSum = 0; $sampleCount = 0
    for ($y=0; $y -lt 512; $y++) {
        for ($x=0; $x -lt 512; $x++) {
            if ($before.GetPixel($x,$y).A -ne $corrected.GetPixel($x,$y).A) { $alphaChanges++ }
        }
    }
    $region = $job.Sample
    for ($y=$region[1]; $y -lt ($region[1]+$region[3]); $y++) {
        for ($x=$region[0]; $x -lt ($region[0]+$region[2]); $x++) {
            $p = $reference.GetPixel($x,$y); $q = $corrected.GetPixel($x,$y)
            if ($p.ToArgb() -ne $q.ToArgb()) { $sampleMismatch++ }
            $refSampleSum+=($p.R+$p.G+$p.B)/3.0; $outSampleSum+=($q.R+$q.G+$q.B)/3.0; $sampleCount++
        }
    }
    if ($alphaChanges -ne 0 -or $sampleMismatch -ne 0) { throw "Color correction invariant failed: view=$($job.View) alphaChanges=$alphaChanges sampleMismatch=$sampleMismatch" }
    if ($job.View -eq 'front') {
        for ($y=0; $y -lt 512; $y+=4) {
            for ($x=0; $x -lt 512; $x+=4) {
                $blockPixel = $corrected.GetPixel($x,$y).ToArgb()
                for ($dy=0; $dy -lt 4; $dy++) { for ($dx=0; $dx -lt 4; $dx++) { if ($corrected.GetPixel($x+$dx,$y+$dy).ToArgb() -ne $blockPixel) { throw 'Front logical pixel grid changed.' } } }
            }
        }
    }
    $correctedPath = Join-Path $runDirectory ($job.View+'_corrected.png')
    $corrected.Save($correctedPath,[System.Drawing.Imaging.ImageFormat]::Png)
    $crop = if ($job.View -eq 'topdown') { [System.Drawing.Rectangle]::new(206,214,100,84) } else { [System.Drawing.Rectangle]::new(136,24,240,464) }
    $scale = if ($job.View -eq 'topdown') { 4 } else { 1 }
    $panelWidth = $crop.Width*$scale; $panelHeight = $crop.Height*$scale
    $preview = [System.Drawing.Bitmap]::new(3*$panelWidth+32,$panelHeight+32)
    $graphics = [System.Drawing.Graphics]::FromImage($preview)
    $graphics.Clear([System.Drawing.Color]::FromArgb(188,191,192))
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $bitmaps = @($reference,$before,$corrected)
    for ($i=0; $i -lt 3; $i++) { $graphics.DrawImage($bitmaps[$i],[System.Drawing.Rectangle]::new(8+$i*($panelWidth+8),16,$panelWidth,$panelHeight),$crop,[System.Drawing.GraphicsUnit]::Pixel) }
    $preview.Save((Join-Path $runDirectory ($job.View+'_comparison.png')),[System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose(); $preview.Dispose(); $corrected.Dispose(); $before.Dispose(); $reference.Dispose()
    if ((Get-FileHash -LiteralPath $targetPath).Hash -ne $beforeHash -or (Get-FileHash -LiteralPath $referencePath).Hash -ne $referenceHash) { throw 'Source asset changed while staging.' }
    $auditRecords += [pscustomobject]@{ View=$job.View; Target=$job.Target; Reference=$job.Reference; TargetHash=$beforeHash; MetaHash=$metaHash; ReferenceHash=$referenceHash; CorrectedHash=(Get-FileHash -LiteralPath $correctedPath).Hash; ChangedPixels=$changed; ProtectedFeaturePixels=$protected; ReferencePaintPixels=$verifiedPaint; AlphaChanges=$alphaChanges; SampleMismatch=$sampleMismatch; ReferenceSampleMean=[Math]::Round($refSampleSum/$sampleCount,3); CorrectedSampleMean=[Math]::Round($outSampleSum/$sampleCount,3) }
}
[System.IO.File]::WriteAllText((Join-Path $runDirectory 'audit.json'),($auditRecords|ConvertTo-Json -Depth 4),[System.Text.UTF8Encoding]::new($false))
$auditRecords | Format-Table View,ChangedPixels,ProtectedFeaturePixels,AlphaChanges,SampleMismatch,ReferenceSampleMean,CorrectedSampleMean -AutoSize
Write-Output "Staged run directory: $runDirectory"
