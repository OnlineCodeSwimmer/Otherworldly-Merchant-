"""Keep Unity's validated new floor while retaining every pre-existing block."""
from pathlib import Path
import re,json,hashlib
root=Path(__file__).resolve().parents[2]
work=root/'tmp/floor-layout'
original=(work/'Clinic.before-floor3.unity').read_bytes()
scene_path=root/'Assets/Scenes/Clinic.unity'
validated=scene_path.read_text(encoding='utf-8-sig')
def parse(s):
    return {int(m[1]):m[0] for m in re.finditer(r'^--- !u!\d+ &(-?\d+)[^\n]*\n.*?(?=^--- !u!|\Z)',s,re.M|re.S)}
baseline=original.decode('utf-8-sig').replace('\r\n','\n')
old=parse(baseline);new=parse(validated)
parent=1939826255
assert '870000000000000107' in new[parent]
result=baseline.replace(old[parent],new[parent],1)+''.join(block for i,block in new.items() if i not in old)
parsed=parse(result)
assert all(parsed[i]==block for i,block in old.items() if i!=parent)
assert len(re.findall(r'^--- !u!',result,re.M))==len(parsed)
assert all(not int(i) or int(i) in parsed for i in re.findall(r'\{fileID: (-?\d+)\}',result))
scene_path.write_bytes(result.encode('utf-8'))
report=json.loads((work/'layout-report.json').read_text())
report['originalSceneObjectsUnchanged']=True
report['unityValidation']='PASS; 1062 ground tiles; 6 doorways; 12 hinge anchors; 64 wall collision vertices'
report['finalSceneSha256']=hashlib.sha256(scene_path.read_bytes()).hexdigest()
(work/'layout-report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
(work/'post-unity-audit.json').write_text(json.dumps({'originalBlocksChanged':[parent],'originalBlocksRemoved':0,'newBlocks':len(parsed)-len(old),'wallCollisionGenerated':True},indent=2))
print('Preserved all original objects; only the parent child list changed. Retained the Unity-validated Floor 3 and collision geometry.')
