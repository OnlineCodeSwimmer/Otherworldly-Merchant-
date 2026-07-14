using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEditor.UI;
using UnityEngine;
using UnityEngine.InputSystem;

public class InventoryManager : MonoBehaviour
{
    public static InventoryManager instance;
    //Other Script
    [Header("Other Script")]
    public InventoryItemToolTip inventoryItemToolTip;
    
    //HighLighter
    [Header("HighLighter")]
    public RectTransform highlighter;
    private Vector2Int oldPosition;


    //Item Variable
    public InventoryGrid selectedInventoryGrid;
    private InventoryItem selectedItem;
    private InventoryItem overlapItem;
    private InventoryItem inventoryItemToHighlight;
    private RectTransform selectedItemRectTransform;




    //Input Variable
    public PlayerInput playerInput;

    //Inventroy UI
    [Header("Inventory UI")]
    public GameObject inventoryUIpanel;
    public GameObject mainInventoryUI;
    public GameObject[] inventoryWindows;

    //Inventory Warning
    [Header("Inventory Warning")]
    public TextMeshProUGUI inventoryWarningText;
    public float warningShowTime = 1.5f;


    private void Awake()
    {
        playerInput = new PlayerInput();

        if (instance == null)
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else if(instance!= this)
        {
            Destroy(gameObject);
        }

    }


    void Update()
    {

        if (mainInventoryUI == null || mainInventoryUI.activeSelf == false)
        {
            if (highlighter != null)
            {
                highlighter.gameObject.SetActive(false);
            }

            if (inventoryItemToolTip != null)
            {
                inventoryItemToolTip.Hide();
            }

            selectedInventoryGrid = null;
            return;
        }

        ItemIconDrag();
        HandleHighlight();
        HandleTooltip();
    }



    private void OnEnable()
    {
        UIInputSubscribe();
    }

    private void OnDisable()
    {
        playerInput.UI.Disable();
        UIInputUnsubscribe();
     }




    private void LeftMouseButtonPress(InputAction.CallbackContext context)
    {
        if (selectedInventoryGrid == null) return; 
        Vector2Int tileGridPosition = GetTileGridPosition();
        if (selectedItem == null)
        {
            PickUpInventoryItem(tileGridPosition);
        }
        else
        {
            PlaceInventoryItem(tileGridPosition);
        }
    }


    private Vector2Int GetTileGridPosition()
    {
        Vector2 mouseposition = Mouse.current.position.ReadValue();

        if (selectedItem != null)
        {
            mouseposition.x -= (selectedItem.Width - 1) * selectedInventoryGrid.tileSizeWidth / 2;
            mouseposition.y += (selectedItem.Height - 1) * selectedInventoryGrid.tileSizeHeight / 2;
        }

        return selectedInventoryGrid.GetGridPosition(mouseposition);
        ;


    }

    private void PickUpInventoryItem(Vector2Int tileGridPosition)
    {
        selectedItem = selectedInventoryGrid.PickUpInventoryItem(tileGridPosition.x, tileGridPosition.y);
        if (selectedItem != null)
        {
            selectedItemRectTransform = selectedItem.GetComponent<RectTransform>();
        }
    }

    private void PlaceInventoryItem(Vector2Int tileGridPosition)
    {
        bool complete = selectedInventoryGrid.PlaceInventoryItem(selectedItem, tileGridPosition.x, tileGridPosition.y, ref overlapItem);
        if (complete) selectedItem = null;
        if (overlapItem != null)
        {
            selectedItem = overlapItem;
            overlapItem = null;
            selectedItemRectTransform = selectedItem.GetComponent<RectTransform>();
        }
    }

    private void ItemIconDrag()
    {
        if (selectedItem != null)
            selectedItemRectTransform.position = Mouse.current.position.ReadValue();
    }

    private void RotateItem(InputAction.CallbackContext context)
    {
        if (selectedItem == null) return;
        selectedItem.Rotate();
    }

    //HighLighter
    private void HandleHighlight()
    {
        if (selectedInventoryGrid == null)
        {
            HighlighterShow(false);
            return;
        }
        Vector2Int positionOnGrid = GetTileGridPosition();

        if (oldPosition != positionOnGrid) // Optimization: if the mouse is still on the same grid position, skip the following code to save performance.
        {
            oldPosition = positionOnGrid;
        }
        else
        {
            return;
        }


        if (selectedItem == null)
        {
            inventoryItemToHighlight = selectedInventoryGrid.GetItem(positionOnGrid.x, positionOnGrid.y);
            if (inventoryItemToHighlight != null)
            {
                HighlighterShow(true);
                HighlighterSetSize(inventoryItemToHighlight);
                HighlighterSetPosition(inventoryItemToHighlight);
            }
            else
            {
                HighlighterShow(false);
            }
        }
        else
        {
            if (selectedInventoryGrid.BoundryCheck(positionOnGrid.x, positionOnGrid.y, selectedItem.Width, selectedItem.Height))
            {
                HighlighterShow(true);
                HighlighterSetSize(selectedItem);
                HighlighterSetPosition(selectedItem, positionOnGrid.x, positionOnGrid.y);
            }
            else
            {
                HighlighterShow(false);
            }

        }
    }



    private void HighlighterShow(bool b)
    {
        highlighter.gameObject.SetActive(b);
    }

    public void HighlighterSetSize(InventoryItem targetItem)
    {
        Vector2 highlighterSize = new Vector2();
        highlighterSize.x = targetItem.Width * selectedInventoryGrid.tileSizeWidth;
        highlighterSize.y = targetItem.Height * selectedInventoryGrid.tileSizeHeight;
        highlighter.sizeDelta = highlighterSize;
    }



    public void HighlighterSetPosition(InventoryItem targetItem)
    {
        highlighter.SetParent(selectedInventoryGrid.GetComponent<RectTransform>());

        Vector2 pos = selectedInventoryGrid.CalculatePositionOnGrid(targetItem, targetItem.onGridPositionX, targetItem.onGridPositionY);

        highlighter.localPosition = pos;
    }


    public void HighlighterSetPosition(InventoryItem targetItem, int highlighterSetPositionX, int highlighterSetPositionposY)
    {
        highlighter.SetParent(selectedInventoryGrid.GetComponent<RectTransform>());
        Vector2 highligherPosition = selectedInventoryGrid.CalculatePositionOnGrid(targetItem, highlighterSetPositionX, highlighterSetPositionposY);
        highlighter.localPosition = highligherPosition;
    }

    //Inventory UI Open and Close

    public void OpenInventoryWindow(string name)
    {
        inventoryUIpanel.SetActive(true);
        mainInventoryUI.SetActive(true);
        foreach(GameObject window in inventoryWindows)
        {
            if(window.name == name)
            {
                window.SetActive(true);
                return;
            }
        }

        Debug.LogError("Inventory window not found: " + name);

    }

    public void ColseInventoryWindow(string name)
    {

        foreach (GameObject window in inventoryWindows)
        {
            if (window.name == name)
            {
                window.SetActive(false);
                return;
            }
        }

        Debug.LogError("Inventory window not found: " + name);

    }
    public void CloseAllInventories()
    {
        foreach (GameObject window in inventoryWindows)
        {
            if (window != null)
            {
                window.SetActive(false);
            }
        }

        mainInventoryUI.SetActive(false);
    }




    //Inventory Switch
    private void CloseInventory(InputAction.CallbackContext context)
    {
        if (!mainInventoryUI.activeSelf) return;

        if (selectedItem != null)
        {
            if (!PoolManager.instance.HasActiveObject("InventoryWarning"))
            {

                GameObject text = PoolManager.instance.Get("InventoryWarning");
                text.transform.SetParent(mainInventoryUI.transform);
                text.transform.SetAsLastSibling();
                text.GetComponent<RectTransform>().anchoredPosition = new Vector2(140f, -450f);

            }
            return;
        }

        CloseAllInventories();
        selectedInventoryGrid = null;
        oldPosition = new Vector2Int(int.MinValue, int.MinValue);
        playerInput.UI.Disable();
        GameManager.instance.playerController.playerInput.Player.Enable();
        GameManager.instance.SetCustomCursor();
        Time.timeScale = 1;

    }

    private void HandleTooltip()
    {
        if (!mainInventoryUI.activeSelf)
        {
            inventoryItemToolTip.Hide();
            return;
        }

        if (selectedInventoryGrid == null)
        {
            inventoryItemToolTip.Hide();
            return;
        }

        if (selectedItem != null)
        {
            inventoryItemToolTip.Hide();
            return;
        }

        Vector2Int positionOnGrid = GetTileGridPosition();
        InventoryItem item = selectedInventoryGrid.GetItem(positionOnGrid.x, positionOnGrid.y);

        if (item != null)
        {
            inventoryItemToolTip.Show(item);
        }
        else
        {
            inventoryItemToolTip.Hide();
        }
    }





    //Input Area
    private void UIInputSubscribe()
    {
        playerInput.UI.Click.started += LeftMouseButtonPress;
        playerInput.UI.RotateItem.started += RotateItem;
        playerInput.UI.CloseInventory.started += CloseInventory;

    }

    private void UIInputUnsubscribe()
    {
        playerInput.UI.Click.started -= LeftMouseButtonPress;
        playerInput.UI.RotateItem.started -= RotateItem;
        playerInput.UI.CloseInventory.started -= CloseInventory;


    }
}
