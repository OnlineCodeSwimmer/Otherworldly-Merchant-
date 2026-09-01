using System.Collections;
using System.Collections.Generic;
using System.IO;
using Unity.VisualScripting;
using UnityEngine;
using static UnityEditor.Progress;

public class InventorySaveDataManager : MonoBehaviour
{
    [Header("Saved Inventory")]
    public InventoryGrid[] savedInventoryGrids;

    [Header("Inventory ItemData")]
    public InventoryItemData[] allInventoryItemData;

    //SavePath
    private string saveFolder;
    private string savePath; 

    public static InventorySaveDataManager instance;


    private void Awake()
    {
        InitSavePath();
        instance = this; 
    }

    [ContextMenu("Load Game")]
    public void LoadGame()
    {
        if(!File.Exists(savePath))
        {
            Debug.LogWarning("Can't find any save");
            return;
        }

        string json = File.ReadAllText(savePath);
        GameSaveData saveData = JsonUtility.FromJson<GameSaveData>(json);

        foreach (InventoryGrid inventoryGrid in savedInventoryGrids)
        {
            if (inventoryGrid == null)
            {
                Debug.LogWarning("If some saved inventory grid is missing");
                continue;
            }

            InventorySaveData inventorySaveData = FindInventorySaveData(saveData, inventoryGrid.inventoryID);

            if(inventorySaveData == null)
            {
                Debug.LogWarning("If some inventorySaveData is missing: "+ inventoryGrid.inventoryID);
                continue;
            }

            LoadInventory(inventoryGrid, inventorySaveData);
        }
        Debug.Log("Loading complete");
      

    }


    [ContextMenu("SaveGame")]
    public void SaveGame()
    {
        GameSaveData saveData = new GameSaveData();

        foreach (InventoryGrid grid in savedInventoryGrids)
        {
            InventorySaveData inventorySaveData = SaveInventory(grid);
            saveData.inventorysSaveData.Add(inventorySaveData);
        }

        string json= JsonUtility.ToJson(saveData,true);
        File.WriteAllText(savePath, json);
        Debug.Log("Saved successfully");

    }

   public InventorySaveData SaveInventory(InventoryGrid grid)
    {
        InventorySaveData inventorySaveData = new InventorySaveData();
        inventorySaveData.inventoryID = grid.inventoryID;
        inventorySaveData.width = grid.gridSizeWidth;
        inventorySaveData.height = grid.gridSizeHeight;
        List<InventoryItem> inventoryItems =grid.GetAllItems();

        foreach(InventoryItem item in inventoryItems )
        {
            InventoryItemSaveData inventoryItemSaveData = new InventoryItemSaveData();

            inventoryItemSaveData.ItemID=item.inventoryItemData.ItemID;
            inventoryItemSaveData.x = item.onGridPositionX;
            inventoryItemSaveData.y= item.onGridPositionY;
            inventoryItemSaveData.rotationIndex = item.rotationIndex;

            inventorySaveData.itemsSaveData.Add(inventoryItemSaveData);
        }

        return inventorySaveData;
    }

    private InventorySaveData FindInventorySaveData(GameSaveData saveData, string inventoryID)
    {
        foreach (InventorySaveData inventorySaveData in saveData.inventorysSaveData)
        {
            if (inventorySaveData.inventoryID == inventoryID)
            {
                return inventorySaveData;
            }
        }
        Debug.LogWarning("Can't find inventory" + inventoryID);
        return null;
    }

    private InventoryItemData FindInventoryItemData(int ItemId)
    {
        foreach(InventoryItemData itemData in allInventoryItemData)
        {
            if(itemData ==null)
            {
                Debug.LogWarning("If some item data is missing:" );
                continue;
            }
            if(itemData.ItemID==ItemId)
            {
                return itemData;
            }
        }
        Debug.LogWarning("Can't find item:" +ItemId);
        return null;
    }

    private void LoadInventory(InventoryGrid inventorygrid, InventorySaveData inventorySaveData)
    {
        inventorygrid.loadedFromSave = true;

        inventorygrid.ClearGrid();

        foreach(InventoryItemSaveData inventoryItemSaveData in inventorySaveData.itemsSaveData)
        {
            InventoryItemData inventoryItemData = FindInventoryItemData(inventoryItemSaveData.ItemID);

            if(inventoryItemData == null)  continue;

            InventoryItem inventoryItem = PoolManager.instance.Get("Inventory Item Prefab").GetComponent<InventoryItem>();
            inventoryItem.Set(inventoryItemData, inventorygrid);
            inventoryItem.SetRotationIndex(inventoryItemSaveData.rotationIndex);
            inventorygrid.PlaceInventoryItem(inventoryItem, inventoryItemSaveData.x, inventoryItemSaveData.y);


        }
    }

    private void InitSavePath()
    {
        saveFolder = Path.Combine(Application.persistentDataPath, "Save");

        if (!Directory.Exists(saveFolder))
        {
            Directory.CreateDirectory(saveFolder);
        }

        savePath = Path.Combine(saveFolder, "save.json");
    }
}
