using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using static RandomDialogueGenerate;

public class InventoryGrid : MonoBehaviour
{
    //Size
    [Header("TileSize")]
    public float tileSizeWidth = 64;
    public float tileSizeHeight = 64;

    [Header("GridSize")]
    public int gridSizeWidth;
    public int gridSizeHeight;

    //Save
    [Header("Save")]
    public string inventoryID;

    private GameObject inventoryUI;

    //Component
    private RectTransform rectTransform;
    private Canvas canvas;

    //Item Site
    private InventoryItem[,] inventoryItemSlot;

    //Position Variable
    private Vector2Int tileGridPoistion = new Vector2Int();

    //Check Variable
    [HideInInspector] public bool loadedFromSave; //To prevent conflicts between backpack loading and the spawning of pre-configured items

    private void Awake()
    {
        InitGrid();

    }


    public bool PlaceInventoryItem(InventoryItem inventoryItem, int tileGridPositionX, int tileGridPositionY, ref InventoryItem overlapItem)
    {
        if (!BoundryCheck(tileGridPositionX, tileGridPositionY, inventoryItem.Width, inventoryItem.Height)) return false;


        if (!OverlapCheck(tileGridPositionX, tileGridPositionY, inventoryItem.Width, inventoryItem.Height, ref overlapItem))
        {
            overlapItem = null;
            return false;
        }

        if (overlapItem != null)
        {
            CleaningGridItem(overlapItem);
        }

        RectTransform itemRectTransform = inventoryItem.GetComponent<RectTransform>();
        itemRectTransform.SetParent(rectTransform, false);

        for (int x = 0; x < inventoryItem.Width; x++)
        {
            for (int y = 0; y < inventoryItem.Height; y++)
            {
                inventoryItemSlot[tileGridPositionX + x, tileGridPositionY + y] = inventoryItem;
            }
        }

        inventoryItem.onGridPositionX = tileGridPositionX;
        inventoryItem.onGridPositionY = tileGridPositionY;

        Vector2 position = CalculatePositionOnGrid(inventoryItem, tileGridPositionX, tileGridPositionY);

        itemRectTransform.localPosition = position;
        return true;
    }


    public void PlaceInventoryItem(InventoryItem inventoryItem, int tileGridPositionX, int tileGridPositionY)
    {
        RectTransform itemRectTransform = inventoryItem.GetComponent<RectTransform>();
        itemRectTransform.SetParent(rectTransform, false);

        for (int x = 0; x < inventoryItem.Width; x++)
        {
            for (int y = 0; y < inventoryItem.Height; y++)
            {
                inventoryItemSlot[tileGridPositionX + x, tileGridPositionY + y] = inventoryItem;
            }
        }

        inventoryItem.onGridPositionX = tileGridPositionX;
        inventoryItem.onGridPositionY = tileGridPositionY;

        Vector2 position = CalculatePositionOnGrid(inventoryItem, tileGridPositionX, tileGridPositionY);

        itemRectTransform.localPosition = position;
    }

    public InventoryItem PickUpInventoryItem(int tileGridPositionX, int tileGridPositionY)
    {
        InventoryItem inventoryItem = inventoryItemSlot[tileGridPositionX, tileGridPositionY];
        if (inventoryItem == null) return null;

        inventoryItem.GetComponent<RectTransform>().SetParent(inventoryUI.transform, false); ;
        CleaningGridItem(inventoryItem);
        return inventoryItem;
    }


    private void CleaningGridItem(InventoryItem inventoryItem)
    {
        for (int x = 0; x < inventoryItem.Width; x++)
        {
            for (int y = 0; y < inventoryItem.Height; y++)
            {
                inventoryItemSlot[inventoryItem.onGridPositionX + x, inventoryItem.onGridPositionY + y] = null;
            }
        }
    }




    public Vector2Int GetGridPosition(Vector2 mousePosition)
    {

        RectTransformUtility.ScreenPointToLocalPointInRectangle(
            rectTransform,
            mousePosition,
            canvas.worldCamera,
            out Vector2 mouseLocalPoint
        );

        float x = mouseLocalPoint.x + rectTransform.rect.width * rectTransform.pivot.x;
        float y = rectTransform.rect.height * (1 - rectTransform.pivot.y) - mouseLocalPoint.y;

        tileGridPoistion.x = Mathf.FloorToInt(x / tileSizeWidth);
        tileGridPoistion.y = Mathf.FloorToInt(y / tileSizeHeight);

        return tileGridPoistion;
    }




    public Vector2 CalculatePositionOnGrid(InventoryItem inventoryItem, int tileGridPositionX, int tileGridPositionY) //Returns the position where the item should be placed, allowing it to fit properly within the grid cells.
    {
        Vector2 position = new Vector2();
        position.x = tileGridPositionX * tileSizeWidth + tileSizeWidth * inventoryItem.Width / 2;
        position.y = -(tileGridPositionY * tileSizeHeight + tileSizeHeight * inventoryItem.Height / 2);
        return position;

    }

    public bool OverlapCheck(int tileGridPositionX, int tileGridPositionY, int Width, int Height)
    {
        for (int x = 0; x < Width; x++)
        {
            for (int y = 0; y < Height; y++)
            {
                if (inventoryItemSlot[tileGridPositionX + x, tileGridPositionY + y] != null)
                {
                    return false;
                }

            }
        }
        return true;
    }



    public bool OverlapCheck(int tileGridPositionX, int tileGridPositionY, int Width, int Height, ref InventoryItem overlapItem)
    {
        for (int x = 0; x < Width; x++)
        {
            for (int y = 0; y < Height; y++)
            {
                if (inventoryItemSlot[tileGridPositionX + x, tileGridPositionY + y] != null)
                {
                    if (overlapItem == null)
                    {
                        overlapItem = inventoryItemSlot[tileGridPositionX + x, tileGridPositionY + y];
                    }
                    else
                    {
                        if (overlapItem != inventoryItemSlot[tileGridPositionX + x, tileGridPositionY + y])
                        {
                            return false;
                        }
                    }
                }

            }
        }
        return true;
    }

    public bool BoundryCheck(int tileGridPositionX, int tileGridPositionY, int width, int height)
    {
        if (tileGridPositionX < 0 || tileGridPositionY < 0) return false;

        tileGridPositionX += width - 1;
        tileGridPositionY += height - 1;

        if (tileGridPositionX >= gridSizeWidth || tileGridPositionY >= gridSizeHeight) return false;

        return true;
    }


    public InventoryItem GetItem(int x, int y)
    {
        return inventoryItemSlot[x, y];
    }

    public List<InventoryItem> GetAllItems()
    {
        InitGrid();
        List<InventoryItem> inventoryitems = new List<InventoryItem>();

        for (int y = 0; y < gridSizeHeight; y++)
        {
            for (int x = 0; x < gridSizeWidth; x++)
            {
                InventoryItem inventoryitem = inventoryItemSlot[x, y];
                if (inventoryitem == null) continue;


                if (inventoryitems.Contains(inventoryitem)) continue;

                inventoryitems.Add(inventoryitem);
            }
        }

        return inventoryitems;
    }




    public int GetItemCount(int ItemID)
    {
        int count = 0;

        foreach(InventoryItem item in GetAllItems())
        {
            if(item.inventoryItemData.ItemID == ItemID)
            {
                count++;
            }
        }

        return count;   
    }

    public bool HasRequiredItems(List<ItemRequirement> requirements)
    {

        Dictionary<int, int> requiredAmounts = BuildRequiredAmounts(requirements);

        foreach(KeyValuePair<int,int> requitement in requiredAmounts)
        {
            int itemID =requitement.Key;
            int requiredAmount=requitement.Value;

            if(GetItemCount(itemID) < requiredAmount) return false; 
            
        }

        return true;
    }

    public void RemoveRequiredItems(List<ItemRequirement> requirements)
    {

        Dictionary<int, int> requiredAmounts=BuildRequiredAmounts(requirements);
        List<InventoryItem> itemsToRemove = new List<InventoryItem>();

        foreach(InventoryItem item in GetAllItems())
        {
            int itemID = item.inventoryItemData.ItemID;

            if (!requiredAmounts.ContainsKey(itemID)) continue;

            if (requiredAmounts[itemID]<=0) continue;   

            itemsToRemove.Add(item);
            requiredAmounts[itemID]--;
        }

        foreach(InventoryItem item in itemsToRemove)
        {
            CleaningGridItem(item);
            item.transform.SetParent(PoolManager.instance.transform);
            item.gameObject.SetActive(false);
        }

    }


    private Dictionary<int, int> BuildRequiredAmounts(List<ItemRequirement> requirements)
    {
        Dictionary<int, int> requiredAmounts = new Dictionary<int, int>();

        foreach (ItemRequirement requirement in requirements)
        {
            int itemID = requirement.inventoryItemData.ItemID;
            int amount = requirement.amount;

            if (requiredAmounts.ContainsKey(itemID))
            {
                requiredAmounts[itemID] += amount;
            }
            else
            {
                requiredAmounts.Add(itemID, amount);
            }
        }

        return requiredAmounts;
    }




    public void ClearGrid()
    {
        List<InventoryItem> inventoryitems= GetAllItems();

        foreach(InventoryItem item in inventoryitems)
        {
            if(item !=null)
            {
                item.transform.SetParent(PoolManager.instance.transform,false);
                item.gameObject.SetActive(false);
            }
        }
        inventoryItemSlot = new InventoryItem[gridSizeWidth, gridSizeHeight];

    }

    private void InitGrid()
    {
        rectTransform = GetComponent<RectTransform>();

        if (inventoryUI == null && InventoryManager.instance != null)
        {
            inventoryUI = InventoryManager.instance.mainInventoryUI;
        }

        if (canvas == null)
        {
            canvas = GetComponentInParent<Canvas>(true);
        }

        if (string.IsNullOrEmpty(inventoryID))
        {
            Debug.LogWarning("Inventory ID is null");
        }

        if (inventoryItemSlot == null)
        {
            inventoryItemSlot = new InventoryItem[gridSizeWidth, gridSizeHeight];
        }

        Vector2 size = new Vector2(
            gridSizeWidth * tileSizeWidth,
            gridSizeHeight * tileSizeHeight
        );

        rectTransform.sizeDelta = size;
    }
}
