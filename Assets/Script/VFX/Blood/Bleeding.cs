using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bleeding : MonoBehaviour
{

    //Prefab
    [Header("Prefab")]
    public string bloodSparyName;

    public void BloodSpawn(Transform damageSource)
    {
        Vector2 spawnDirction= (transform.position - damageSource.position).normalized;
        GameObject bloodSpray = PoolManager.instance.Get(bloodSparyName);
        bloodSpray.transform.SetParent(transform);
        bloodSpray.transform.position = transform.position;
        bloodSpray.transform.right = spawnDirction;

    }

    public void BloodSpawn(Vector2 DamgeSourceDirection)
    {
        GameObject bloodSpray = PoolManager.instance.Get(bloodSparyName);
        bloodSpray.transform.SetParent(transform);
        bloodSpray.transform.position = transform.position;
        bloodSpray.transform.right = DamgeSourceDirection;
    }

}
