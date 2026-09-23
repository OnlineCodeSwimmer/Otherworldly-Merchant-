from pathlib import Path
import re,json,hashlib
from inspect_scene import ROOT
import render_layout as projected

work=ROOT/'tmp/floor-layout'
report=json.loads((work/'layout-report.json').read_text())
asset=ROOT/'Assets/Scenes/Clinic Floor 3 Layout.unity'
fragment=work/'clinic-fragment.txt'

def fix_hinges(text):
    for h in projected.hinges:
        pat=r'(^--- !u!1001 &'+str(h['instance'])+r'\n)(.*?)(?=^--- !u!|\Z)'
        def patch(m):
            s=m[2]
            for axis in ('x','y'):
                # Replace an existing override only for this particular joint.
                target='{fileID: '+str(h['component'])+', guid: '+h['guid']+', type: 3}'
                p=r'(    - target: '+re.escape(target)+r'\n      propertyPath: m_ConnectedAnchor\.'+axis+r'\n      value: )[^\n]*'
                value=format(h[axis],'.9g')
                if re.search(p,s):s=re.sub(p,lambda a:a[1]+value,s)
                else:s=s.replace('    m_RemovedComponents:',f'    - target: {target}\n      propertyPath: m_ConnectedAnchor.{axis}\n      value: {value}\n      objectReference: {{fileID: 0}}\n    m_RemovedComponents:')
            return m[1]+s
        text=re.sub(pat,patch,text,flags=re.M|re.S)
    return text

for p in (asset,fragment):p.write_text(fix_hinges(p.read_text(encoding='utf-8')),encoding='utf-8')

clinic=ROOT/'Assets/Scenes/Clinic.unity'
before=clinic.read_bytes();original=before.decode('utf-8-sig').replace('\r\n','\n')
assert hashlib.sha256(original.encode()).hexdigest()==report['sourceSceneSha256'],'Clinic changed since inspection; rebuild from the new source before applying.'
assert '  m_Name: Floor 3\n' not in original
root=int(report['ids']['1681993356'])
newfloor=fragment.read_text(encoding='utf-8')
pat=r'(^--- !u!4 &'+str(root)+r'\n)(.*?)(?=^--- !u!|\Z)'
newfloor=re.sub(pat,lambda m:m[1]+m[2].replace('  m_Father: {fileID: 0}','  m_Father: {fileID: 1939826255}'),newfloor,flags=re.M|re.S)

# Only append a child reference to the original Clinic Object transform.
text=before.decode('utf-8-sig');newline='\r\n' if '\r\n' in text else '\n'
pat=r'(^--- !u!4 &1939826255\r?\n)(.*?)(?=^--- !u!|\Z)'
matches=list(re.finditer(pat,text,re.M|re.S));assert len(matches)==1
m=matches[0]
parent=m[2].replace('  m_Father:',f'  - {{fileID: {root}}}'+newline+'  m_Father:')
after=text[:m.start()]+m[1]+parent+text[m.end():]
after+=newfloor.replace('\n',newline)
prefix=b'\xef\xbb\xbf' if before.startswith(b'\xef\xbb\xbf') else b''
(work/'Clinic.before-floor3.unity').write_bytes(before)
clinic.write_bytes(prefix+after.encode('utf-8'))

# The previous scene content must be byte-for-byte recoverable by removing
# exactly the one new parent reference and the appended fragment.
recovered=after[:-len(newfloor.replace('\n',newline))].replace(f'  - {{fileID: {root}}}'+newline,'',1)
assert prefix+recovered.encode('utf-8')==before
allids=[int(v) for v in re.findall(r'^--- !u!\d+ &(-?\d+)',after,re.M)]
assert len(allids)==len(set(allids))
known=set(allids)
unresolved={int(v) for v in re.findall(r'\{fileID: (-?\d+)\}',after) if int(v) and int(v) not in known}
assert not unresolved,unresolved
report['hingeAnchorsUpdated']=len(projected.hinges)
report['originalSceneObjectsUnchanged']=True
report['addedRootFileId']=str(root)
report['finalSceneSha256']=hashlib.sha256(clinic.read_bytes()).hexdigest()
(work/'layout-report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print('Added Floor 3 to Clinic. Original objects unchanged. Updated',len(projected.hinges),'hinge anchors; no duplicate IDs or unresolved local references.')
