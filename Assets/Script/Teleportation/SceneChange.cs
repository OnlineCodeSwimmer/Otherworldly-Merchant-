using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

public class SceneChange : MonoBehaviour
{
    public enum CurrentLocation
    { 
     Home,
     ClinicExit
    
    }
    public CurrentLocation currentLocation;
    public GameObject senceChoose;


    private void OnTriggerEnter2D (Collider2D other)
    {
        if (!other.CompareTag("Player")) return;

        switch(currentLocation)
        { 
            case CurrentLocation.Home:
                PlayerController playerController = GameManager.instance.playerController;

                senceChoose.gameObject.SetActive(true);

                playerController.playerInput.Player.Disable();
                UIManager.instance.playerInput.UI.Enable();
                GameManager.instance.SetDefaultCursor();
                break;


            case CurrentLocation.ClinicExit:
            SceneManager.LoadScene("Home");
             break;
        }
        
    }
}
