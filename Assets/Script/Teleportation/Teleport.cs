using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Teleportation : MonoBehaviour
{
    public enum Type
    { 
     Home,
     Clinic
    
    }
    public Type type;


    private void OnTriggerEnter2D (Collider2D other)
    {
        if (!other.CompareTag("Player")) return;

        switch(type)
        { 
            case Type.Home:
                SceneManager.LoadScene("Home");
                break;


            case Type.Clinic:
            SceneManager.LoadScene("Hospital");
                break;
        }
        
    }
}
