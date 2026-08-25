using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OpenableObject : MonoBehaviour
{
    public string openObjectName;
    public enum OpenObjectType
    {
        ObjectWithInventory,
        StorgeInventory,
        Computer
    }
    public OpenObjectType openObject;
    public GameObject inventoryWindow;
    public GameObject outline;



    private void Awake()
    {
        outline = transform.Find("Outline").gameObject;
    }


    private void Start()
    {
        switch (openObject)
        {
            case OpenObjectType.StorgeInventory:
                Transform inventoryTransform = InventoryManager.instance.transform.Find("Inventory UI/Storage Inventory");
                inventoryWindow = inventoryTransform.gameObject;
                break;
        }

    }
    private void OnTriggerStay2D(Collider2D collision)
    {
        if(!collision.CompareTag("Player")) return;

        PlayerController playerController = GameManager.instance.playerController;

        //If there are multiple boxes, determine which one should be opened.
        if (playerController.openableObject == null)
        {
            GameManager.instance.playerController.openableObject = this;
            outline.SetActive(true);
        }
        else
        {
            float OrignalDistance = Vector2.Distance(playerController.transform.position, playerController.openableObject.transform.position);
            float CurrentDistance = Vector2.Distance(playerController.transform.position,transform.position);
            if(CurrentDistance <=OrignalDistance)
            {
                GameManager.instance.playerController.openableObject = this;
                outline.SetActive(true);
            }
            else
            {
                outline.SetActive(false);
            }
        }


    }

    private void OnTriggerExit2D(Collider2D collision)
    {
        if (!collision.CompareTag("Player")) return;

        PlayerController playerController = GameManager.instance.playerController;

        if (playerController.openableObject == this) playerController.openableObject =null ;

        outline.SetActive(false);

    }


    public void OpenObject()
    {
        GameManager.instance.playerController.playerInput.Player.Disable();

        switch(openObject)
        {
            case OpenObjectType.StorgeInventory:
            case OpenObjectType.ObjectWithInventory:
                InventoryManager.instance.playerInput.UI.Enable();
                InventoryManager.instance.OpenObjectInventory(inventoryWindow);
                break;

            case OpenObjectType.Computer:
                ComputerManager computerManager= GameManager.instance.computerManager.GetComponent<ComputerManager>();
                computerManager.CloseAllWindows();
                computerManager.gameObject.SetActive(true);
                computerManager.OpenWindow(openObjectName);
             break;
        }
       

    }
}

