using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class InventoryItem : MonoBehaviour
{

    public InventoryItemData inventoryItemData;

    public int Height
    {
        get
        {
            if (rotated == false)
            {
                return inventoryItemData.sizeHeight;
            }
            return inventoryItemData.sizeWidth;
        }
    }

    public int Width
    {
        get
        {
            if (rotated == false)
            {
                return inventoryItemData.sizeWidth;
            }
            return inventoryItemData.sizeHeight;
        }
    }

    //Use to save item on gird position
    public int onGridPositionX;
    public int onGridPositionY;

    //Use to Check rotate
    public int rotationIndex;
    public bool rotated
    {
        get
        {
            return rotationIndex % 2 == 1;
        }
    }





    public void Set(InventoryItemData inventoryItemData,InventoryGrid inventoryGrid) 
    {
        this.inventoryItemData = inventoryItemData;

        GetComponent<Image>().sprite = inventoryItemData.itemIcon;

        Vector2 size = new Vector2();
        size.x = Width * inventoryGrid.tileSizeWidth;                 
        size.y = Height * inventoryGrid.tileSizeHeight;
        GetComponent<RectTransform>().sizeDelta = size;
    }

    public void Rotate()
    {
        rotationIndex++;
        
        if(rotationIndex >= 4)
        {
            rotationIndex = 0;
        }

        ApplyRotation();
    }

    private void ApplyRotation()
    {
        RectTransform rectTransform = GetComponent<RectTransform>();
        rectTransform.localRotation = Quaternion.Euler(0, 0, -90f * rotationIndex);
    }

    public void SetRotationIndex(int value)
    {
        rotationIndex = value;
        ApplyRotation();
    }

}









