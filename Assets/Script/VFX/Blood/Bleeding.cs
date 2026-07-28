using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bleeding : MonoBehaviour
{
    //Generate position
    [Header("Generate Position")]
    public GameObject spawnPoint;

    //Prefab
    [Header("Prefab")]
    public string bloodSparyName;

    public void BloodSpawn(Transform DamageSource)
    {
        Vector2 spawnDirction= (spawnPoint.transform.position - DamageSource.position).normalized;
        GameObject bloodSpray = PoolManager.instance.Get(bloodSparyName);
        bloodSpray.transform.SetParent(spawnPoint.transform);
        bloodSpray.transform.position = spawnPoint.transform.position;
        bloodSpray.transform.right = spawnDirction;

    }

}
