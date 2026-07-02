using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OpenableObject : MonoBehaviour
{
    public string openInventoryName;



    private void OnTriggerStay2D(Collider2D collision)
    {
        if(!collision.CompareTag("Player")) return;

        PlayerController playerController = GameManager.instance.playerController;

        if (playerController.openableObject == null)
        {
            GameManager.instance.playerController.openableObject = this;
        }
        else
        {
            float OrignalDistance = Vector2.Distance(playerController.transform.position, playerController.openableObject.transform.position);
            float CurrentDistance = Vector2.Distance(playerController.transform.position,transform.position);
            if(CurrentDistance < OrignalDistance)
            {
                GameManager.instance.playerController.openableObject = this;
            }
        }


    }

    private void OnTriggerExit2D(Collider2D collision)
    {
        if (!collision.CompareTag("Player")) return;

        PlayerController playerController = GameManager.instance.playerController;

        if (playerController.openableObject == this) playerController.openableObject =null ;
        

    }


    public void OpenInventory()
    {
        GameManager.instance.playerController.playerInput.Player.Disable();
        InventoryManager.instance.playerInput.UI.Enable(); 
        InventoryManager.instance.OpenInventoryWindow("Backpack Inventory");
        InventoryManager.instance.OpenInventoryWindow(openInventoryName);
    }
}
