using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PoolManager : MonoBehaviour
{
    //Prefabs Store
    [Header("Prefabs Store")]
    public GameObject[] prefabs;
    private Dictionary<string, List<GameObject>> pools = new Dictionary<string, List<GameObject>>();
    private Dictionary<string, GameObject> prefabDictionary = new Dictionary<string, GameObject>();


    public static PoolManager instance;


    private void Awake()
    {
        instance = this;
        InitPool();

    }

    private void InitPool() //Initialize Object Pool
    {
        foreach (GameObject prefab in prefabs)
        {
            if (prefab == null)
            {
                Debug.LogWarning("Some prefab disapper ");
                continue;
            }

            string prefabName = prefab.name;

            prefabDictionary.Add(prefabName, prefab);
            pools.Add(prefabName, new List<GameObject>());
        }
    }
    public GameObject Get(string prefabName)
    {

        GameObject selectedObject = null;

        if (!prefabDictionary.ContainsKey(prefabName))
        {
            Debug.LogWarning("The prefab is not exist: " + prefabName);
            return null;
        }

        foreach (GameObject item in pools[prefabName]) //Get object from pool, activate if exists, avoid new instantiation
        {
            if (!item.activeSelf)
            {
                selectedObject = item;
                selectedObject.SetActive(true);
                break;
            }
        }

        if (selectedObject == null)
        {
            selectedObject = Instantiate(prefabDictionary[prefabName], transform);
            selectedObject.name = prefabName;
            pools[prefabName].Add(selectedObject);
        }

        return selectedObject;
    }
    public bool HasActiveObject(string prefabName)//Used to check if an object is active 
    {
        if (!pools.ContainsKey(prefabName))
        {
            Debug.LogError("The prefab is not exist: " + prefabName);
            return false;
        }

        foreach (GameObject item in pools[prefabName])
        {
            if (item.activeSelf)
            {
                return true;
            }
        }

        return false;
    }
}




