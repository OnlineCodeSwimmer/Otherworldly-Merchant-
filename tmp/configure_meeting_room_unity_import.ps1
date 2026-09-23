$ErrorActionPreference='Stop'
$folder=Join-Path (Get-Location) 'Assets\AIGC Source\Building\Object\Meeting Room'
$settings=@{
    'meeting_table_modern_topdown_128x384.png.meta'=32
    'meeting_table_modern_topdown_256x768.png.meta'=64
    'meeting_table_modern_topdown_fullres.png.meta'=100
    'meeting_chair_taupe_topdown_64x64.png.meta'=32
    'meeting_chair_taupe_topdown_128x128.png.meta'=64
    'meeting_chair_taupe_topdown_fullres.png.meta'=100
}
foreach($entry in $settings.GetEnumerator()){
    $path=Join-Path $folder $entry.Key
    if(-not (Test-Path -LiteralPath $path)){throw "Missing meta: $path"}
    $text=Get-Content -Raw -LiteralPath $path
    if(([regex]::Matches($text,'filterMode: 1')).Count -ne 1){throw "Unexpected filterMode in $($entry.Key)"}
    if(([regex]::Matches($text,'spritePixelsToUnits: 100')).Count -ne 1){throw "Unexpected PPU in $($entry.Key)"}
    if(([regex]::Matches($text,'textureCompression: 1')).Count -ne 3){throw "Unexpected compression settings in $($entry.Key)"}
    $text=$text.Replace('filterMode: 1','filterMode: 0')
    $text=$text.Replace('spritePixelsToUnits: 100',"spritePixelsToUnits: $($entry.Value)")
    $text=$text.Replace('textureCompression: 1','textureCompression: 0')
    Set-Content -LiteralPath $path -Value $text -Encoding utf8 -NoNewline
}
