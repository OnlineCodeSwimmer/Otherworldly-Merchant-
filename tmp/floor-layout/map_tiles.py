from inspect_scene import *

def tiles(id):
    s=blocks[id][1]
    result={}
    for m in re.finditer(r'  - first: \{x: (-?\d+), y: (-?\d+), z: (-?\d+)\}\n    second:\n(.*?)(?=  - first:|^  m_AnimatedTiles:)',s,re.M|re.S):
        result[tuple(map(int,m.group(1,2,3)))]=m[4]
    return result

if __name__=='__main__':
    for id in (171008837,276111056,1294319946,662521458):
        ts=tiles(id)
        print('\nMAP',id,'count',len(ts),'x',min(t[0] for t in ts),max(t[0] for t in ts),'y',min(t[1] for t in ts),max(t[1] for t in ts))
        if id in (171008837,1294319946):
            for y in range(25,-7,-1):
                print(f'{y:3} '+''.join(format(int(re.search(r'm_TileIndex: (\d+)',ts[(x,y,0)])[1]),'x') if (x,y,0) in ts else ' ' for x in range(-10,46)))
            print(blocks[id][1][blocks[id][1].index('  m_TileAssetArray:'):])
