using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PoolManager : MonoBehaviour
{
    //Prefabs Data
    [Header("Prefabs Data")]
    private Dictionary<GameObject, List<GameObject>> pools = new Dictionary<GameObject, List<GameObject>>();


    public static PoolManager instance;


    private void Awake()
    {
        instance = this;

    }

    public GameObject Get(GameObject prefab)
    {

        if (!pools.TryGetValue(prefab, out List<GameObject> pool))
        {
            pool = new List<GameObject>();
            pools.Add(prefab, pool);
        }

        foreach (GameObject item in pool)
        {
            if (item != null && !item.activeSelf && item.transform.parent == transform)
            {
                item.SetActive(true);
                return item;
            }
        }

        GameObject newObject = Instantiate(prefab, transform);
        newObject.name = prefab.name;
        pool.Add(newObject);


        return newObject;
    }

    //This is for the Inventory warning, but the way it's generated is somewhat redundant£¬remember to optimize it later.
    public bool HasActiveObject(GameObject prefab)
    {
        if (!pools.TryGetValue(prefab, out List<GameObject> pool))
        {
            return false;
        }

        foreach (GameObject item in pool)
        {
            if (item.activeSelf)
            {
                return true;
            }
        }

        return false;
    }


    public void Recycle(GameObject gameObject, bool keepWorldTransform = true)
    {
        gameObject.SetActive(false);
        gameObject.transform.SetParent(transform, keepWorldTransform);
    }


}




