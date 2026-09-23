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

    [Header("Position adjustment")]
    public Vector2 offset = new Vector2(25f, -25f);
    public float screenPadding = 10f;
    private Vector3[] corners = new Vector3[4];


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


        //Determine if the pop-up box exceeds the screen boundaries
        rectTransform.GetWorldCorners(corners);
        Vector2 correction = Vector2.zero;


        if (corners[2].x > Screen.width - screenPadding)
        {
            correction.x -= corners[2].x - (Screen.width - screenPadding);
        }

        if (corners[0].y < screenPadding)
        {
            correction.y += screenPadding - corners[0].y;
        }

        rectTransform.position += (Vector3)correction;
    }


}


