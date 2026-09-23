Add-Type -AssemblyName System.Drawing
$benchJobs = @(
    @{ Source = 'exec-4aa3ba27-fa42-40dc-8dc8-e642f437b1f1.png'; Width = 96; Name = 'clinic_bench_blue_short_topdown_96x32.png' },
    @{ Source = 'exec-cc2ad690-3b8c-4331-9936-36ffeab6f27b.png'; Width = 128; Name = 'clinic_bench_blue_medium_topdown_128x32.png' },
    @{ Source = 'exec-084b363c-c997-4ec8-bb84-435c14450d4b.png'; Width = 160; Name = 'clinic_bench_blue_long_topdown_160x32.png' }
)
foreach ($benchJob in $benchJobs) {
    $benchTarget = Join-Path (Get-Location) ('Assets\AIGC Source\Building\Object\' + $benchJob.Name)
    if (Test-Path -LiteralPath $benchTarget) { throw "Refusing to overwrite: $benchTarget" }
    $benchSource = [System.Drawing.Bitmap]::new(('C:\Users\望兴腾\.codex\generated_images\01a0ad86-844a-7e50-9b5e-4843c923a4c1\' + $benchJob.Source))
    if ($benchSource.GetPixel(0,0).A -ge 128) { throw 'Source must have genuine transparent background.' }
    $left = $benchSource.Width; $top = $benchSource.Height; $right = -1; $bottom = -1
    for ($y = 0; $y -lt $benchSource.Height; $y++) {
        for ($x = 0; $x -lt $benchSource.Width; $x++) {
            $color = $benchSource.GetPixel($x, $y)
            if ($color.A -ge 128) {
                $benchSource.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $color.R, $color.G, $color.B))
                $left = [Math]::Min($left, $x); $top = [Math]::Min($top, $y)
                $right = [Math]::Max($right, $x); $bottom = [Math]::Max($bottom, $y)
            } else { $benchSource.SetPixel($x, $y, [System.Drawing.Color]::Transparent) }
        }
    }
    if ($right -lt 0) { throw 'No opaque bench pixels found.' }
    $benchBounds = [System.Drawing.Rectangle]::new($left, $top, $right - $left + 1, $bottom - $top + 1)
    $benchOutput = [System.Drawing.Bitmap]::new([int]$benchJob.Width, 32, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $benchGraphics = [System.Drawing.Graphics]::FromImage($benchOutput)
    $benchGraphics.Clear([System.Drawing.Color]::Transparent)
    $benchGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $benchGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $benchGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    # Uniform twenty-pixel seat depth for all three game-ready length variants.
    $benchDestination = [System.Drawing.Rectangle]::new(2, 6, [int]$benchJob.Width - 4, 20)
    $benchGraphics.DrawImage($benchSource, $benchDestination, $benchBounds, [System.Drawing.GraphicsUnit]::Pixel)
    $benchOutput.Save($benchTarget, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output "Saved: $benchTarget; canvas=$($benchOutput.Width)x$($benchOutput.Height); seatDepth=20; cornerAlpha=$($benchOutput.GetPixel(0,0).A)"
    $benchGraphics.Dispose(); $benchOutput.Dispose(); $benchSource.Dispose()
}
