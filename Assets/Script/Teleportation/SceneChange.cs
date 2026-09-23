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
     ClinicExit,
     ClinicFloor2Down,
     ClinicFloor1Up,
    
    }
    public CurrentLocation currentLocation;
    public GameObject senceChoose;


    private void OnTriggerEnter2D (Collider2D collider)
    {
        if (!collider.CompareTag("Player")) return;

        Transform player = collider.transform;

        switch (currentLocation)
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

            case CurrentLocation.ClinicFloor2Down:
                player.position = new Vector3 (35.61f, -2.99f, 0);
                break;

            case CurrentLocation.ClinicFloor1Up:
                player.position = new Vector3(156.511f, -2.99f, 0);
                break;
        }
        
    }
}
