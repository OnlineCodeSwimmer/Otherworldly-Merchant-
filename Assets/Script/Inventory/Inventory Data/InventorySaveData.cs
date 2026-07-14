using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
 public class InventoryItemSaveData
{
        public int ItemID;
        public int x;
        public int y;
        public int rotationIndex;
}


[System.Serializable]

public class InventorySaveData
{
    public string inventoryID;
    public int width;
    public int height;
    public List<InventoryItemSaveData> itemsSaveData = new List<InventoryItemSaveData>();
}

public class GameSaveData
{
    public List<InventorySaveData> inventorysSaveData = new List<InventorySaveData>();
}


