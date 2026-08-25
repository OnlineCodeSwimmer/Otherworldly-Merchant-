using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationEvent: MonoBehaviour
{
    public void AnimationFinish()
    {
        gameObject.SetActive(false);
        //transform.SetParent(PoolManager.instance.transform);
    }
}
