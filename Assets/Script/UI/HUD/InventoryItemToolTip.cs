using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class InventoryItemToolTip : MonoBehaviour
{

    [Header("Text")]
    public Text nameText;
    public Text descriptionText;

    [Header("Position")]
    public Vector2 offset = new Vector2(25f, -25f);

    private RectTransform rectTransform;




    private void Awake()
    {
         rectTransform = GetComponent<RectTransform>();

        gameObject.SetActive(false);
    }
    private void Update()
    {
        FollowMouse();
    }
    public void Hide()
    {
        gameObject.SetActive(false);
    }

    public void Show(InventoryItem inventoryItem)
    {
        InventoryItemData data = inventoryItem.inventoryItemData;

        gameObject.SetActive(true);

        nameText.text = data.itemName;
        nameText.color = data.itemNameColor;

        descriptionText.text = data.itemDescription;

        FollowMouse();

        gameObject.SetActive(true);



    }

    private void FollowMouse()
    {
        if (!gameObject.activeSelf) return;
        Vector2 mousePosition = Mouse.current.position.ReadValue();



        rectTransform.position = mousePosition + offset;
    }


}


