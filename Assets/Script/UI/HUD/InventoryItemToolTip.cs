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

        nameText.text = data.itemName;
        nameText.color = data.itemNameColor;
        descriptionText.text = data.itemDescription;

        FollowMouse();

        Canvas targetCanvas = inventoryItem.GetComponentInParent<Canvas>();
        transform.SetParent(targetCanvas.transform);

        gameObject.SetActive(true);



    }
    private void EnsureInitialized()
    {
        if (rectTransform == null)
        {
            rectTransform = GetComponent<RectTransform>();
        }
    }
    private void FollowMouse()
    {
        EnsureInitialized();

        Vector2 mousePosition = Mouse.current.position.ReadValue();

        rectTransform.position = mousePosition + offset;
    }


}


