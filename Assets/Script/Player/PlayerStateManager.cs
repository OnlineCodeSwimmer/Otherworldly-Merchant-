using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerStateManager : MonoBehaviour
{
    public static PlayerStateManager instance;

    //State
    [Header("Player various states")]
    public float balance=10f;
    public float debt=1000f;
    public float health;

    private void Awake()
    {
        if(instance == null)
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else if(instance!=this)
        {
            Destroy(gameObject);
         }
    }



}
