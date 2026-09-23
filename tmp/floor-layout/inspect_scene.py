from pathlib import Path
import re, json, collections

ROOT = Path(__file__).resolve().parents[2]
scene = (ROOT/'Assets/Scenes/Clinic.unity').read_text(encoding='utf-8-sig')
blocks = {}
for m in re.finditer(r'^--- !u!(\d+) &(\d+)([^\n]*)\n(.*?)(?=^--- !u!|\Z)', scene, re.M | re.S):
    blocks[int(m[2])] = (int(m[1]), m[4])

def field(s, key, default=''):
    m = re.search(r'^  '+re.escape(key)+r': (.*)$', s, re.M)
    return m[1] if m else default

def ref(s, key):
    m = re.search(r'\b'+re.escape(key)+r': \{fileID: (\d+)', s)
    return int(m[1]) if m else 0

def vec(s, key):
    return [float(v) for v in re.findall(r'[xyzw]: (-?[\d.eE+-]+)', field(s,key))]

prefab_paths={}
for p in (ROOT/'Assets').rglob('*.prefab.meta'):
    m=re.search(r'^guid: (\w+)',p.read_text(encoding='utf-8-sig'),re.M)
    if m: prefab_paths[m[1]]=str(p.relative_to(ROOT))[:-5]

nodes={}
for id,(kind,s) in blocks.items():
    if kind !=4: continue
    if 'stripped' not in s and 'm_GameObject:' in s:
        go=blocks[ref(s,'m_GameObject')][1]
        comps=[int(x) for x in re.findall(r'component: \{fileID: (\d+)', go)]
        nodes[id]={'id':id,'name':field(go,'m_Name'),'parent':ref(s,'m_Father'),'pos':vec(s,'m_LocalPosition'),'scale':vec(s,'m_LocalScale'),'components':[(c,blocks[c][0]) for c in comps]}
    elif ref(s,'m_PrefabInstance'):
        inst=blocks[ref(s,'m_PrefabInstance')][1]
        guid=re.search(r'm_SourcePrefab: \{.*guid: (\w+)',inst)[1]
        vals=dict(re.findall(r'propertyPath: (.*?)\n      value: (.*?)\n',inst))
        nodes[id]={'id':id,'name':vals.get('m_Name',prefab_paths.get(guid,guid)),'parent':ref(inst,'m_TransformParent'),'pos':[float(vals.get('m_LocalPosition.'+a,0)) for a in 'xyz'],'scale':[float(vals.get('m_LocalScale.'+a,1)) for a in 'xyz'],'prefab':prefab_paths.get(guid,guid),'instance':ref(s,'m_PrefabInstance'),'components':[]}

def walk(id,depth=0):
    n=nodes.get(id)
    if not n:return
    print('  '*depth+f'{n["id"]} {n["name"]} pos={n["pos"]} scale={n["scale"]} comps={n["components"]}')
    for ch in nodes.values():
        if ch['parent']==id:walk(ch['id'],depth+1)

if __name__=='__main__':
    walk(1681993356)
    walk(126738656)
    Path(__file__).with_name('scene_inventory.json').write_text(json.dumps(nodes,ensure_ascii=False,indent=2),encoding='utf-8')
    for id,(kind,s) in blocks.items():
        if kind in (1839735485,156049354):
            print('\nTILEMAP',id,kind, 'go',ref(s,'m_GameObject'), 'size',field(s,'m_Size'), 'origin',field(s,'m_Origin'))
            print(s[:2200])
