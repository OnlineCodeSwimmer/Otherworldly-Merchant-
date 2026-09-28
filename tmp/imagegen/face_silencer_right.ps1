$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies @([System.Drawing.Bitmap].Assembly.Location, [System.Drawing.Rectangle].Assembly.Location) -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public static class SilencerRightRotation {
    static byte[] Read(Bitmap b) {
        var data = b.LockBits(new Rectangle(0,0,b.Width,b.Height),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
        try {
            if(data.Stride != b.Width*4) throw new Exception("Unexpected bitmap stride");
            var bytes=new byte[b.Width*b.Height*4]; Marshal.Copy(data.Scan0,bytes,0,bytes.Length); return bytes;
        } finally {b.UnlockBits(data);}
    }
    public static void Rotate(string input,string output,int cell,int cols,int rows) {
        using(var src=new Bitmap(input)) {
            if(src.Width!=cell*cols || src.Height!=cell*rows) throw new Exception("Unexpected sheet dimensions: "+input);
            var before=Read(src); var after=(byte[])before.Clone();
            for(int row=0;row<rows;row++) for(int col=0;col<cols;col++)
                for(int y=0;y<cell;y++) for(int x=0;x<cell;x++) {
                    int a=((row*cell+y)*src.Width+col*cell+x)*4;
                    int b=((row*cell+cell-1-x)*src.Width+col*cell+y)*4;
                    Buffer.BlockCopy(before,a,after,b,4);
                }
            using(var dst=new Bitmap(src.Width,src.Height,PixelFormat.Format32bppArgb)) {
                var data=dst.LockBits(new Rectangle(0,0,dst.Width,dst.Height),ImageLockMode.WriteOnly,PixelFormat.Format32bppArgb);
                try {Marshal.Copy(after,0,data.Scan0,after.Length);} finally {dst.UnlockBits(data);}
                dst.Save(output,ImageFormat.Png);
            }
            using(var check=new Bitmap(output)) {
                var saved=Read(check);
                for(int i=0;i<saved.Length;i++) if(saved[i]!=after[i]) throw new Exception("PNG pixel verification failed");
            }
        }
    }
}
'@
$projectRoot = 'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant'
$artRoot = Join-Path $projectRoot 'Assets\AIGC Source\Enemy\Silencer'
$backupRoot = Join-Path $projectRoot ('tmp\imagegen\silencer_before_face_right_' + (Get-Date -Format 'yyyyMMdd_HHmmss'))
New-Item -ItemType Directory -Path $backupRoot | Out-Null
$sheets = @(
    @{Name='Silencer.png'; Cell=518; Cols=4; Rows=1},
    @{Name='Silencer_Run.png'; Cell=518; Cols=4; Rows=1},
    @{Name='Silencer_Attack.png'; Cell=518; Cols=4; Rows=1},
    @{Name='Silencer_Death_Sheet.png'; Cell=640; Cols=3; Rows=2}
)
$protected = @(Get-ChildItem -LiteralPath $artRoot -Filter '*.meta') + @(Get-ChildItem -LiteralPath (Join-Path $projectRoot 'Assets\Animation\Enemy\Silencer') -File)
$protectedHashes = @{}
foreach($file in $protected) { $protectedHashes[$file.FullName] = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash }
foreach($sheet in $sheets) {
    $source = Join-Path $artRoot $sheet.Name
    Copy-Item -LiteralPath $source -Destination (Join-Path $backupRoot $sheet.Name)
    $staged = Join-Path $backupRoot ('right_' + $sheet.Name)
    [SilencerRightRotation]::Rotate($source,$staged,$sheet.Cell,$sheet.Cols,$sheet.Rows)
}
# Commit only after all four sheets pass exact RGBA-pixel verification.
foreach($sheet in $sheets) {
    Copy-Item -LiteralPath (Join-Path $backupRoot ('right_' + $sheet.Name)) -Destination (Join-Path $artRoot $sheet.Name) -Force
    Write-Output ('Rotated and verified: ' + $sheet.Name + ' (' + ($sheet.Cols*$sheet.Rows) + ' frames)')
}
foreach($file in $protected) {
    if((Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash -ne $protectedHashes[$file.FullName]) {throw ('Unexpected metadata/animation change: '+$file.FullName)}
}
Write-Output ('Metadata and animation files unchanged. Backup: '+$backupRoot)
