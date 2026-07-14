using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class InventoryItemGenerate : MonoBehaviour
{

    [Header("Random Amount")]
    public int minGenerateAmount;
    public int maxGenerateAmount;

    [Header("Inventory ItemData")]
    public InventoryItemData[] inventoryItemToGenerateData;
    public InventoryItemData[] randomInventoryItemToGenerateData;

    public GameObject inventoryPrefab;



    //Component
    private InventoryGrid inventoryGrid;

    private void Awake()
    {
        inventoryGrid = GetComponent<InventoryGrid>();
    }

    private void Start()
    {
        GenerateInventoryItem();
    }
    private InventoryItem CreateInventoryItem(InventoryItemData inventoryItemdata)
    {

        if (inventoryItemdata == null) return null;

        InventoryItem inventoryItem = PoolManager.instance.Get("Inventory Item Prefab").GetComponent<InventoryItem>();
        inventoryItem.Set(inventoryItemdata, inventoryGrid);

        return inventoryItem;
    }

    private void PlaceInventoryItem(InventoryItemData inventoryItemdata)
    {
        {
            InventoryItem inventoryItem = CreateInventoryItem(inventoryItemdata);

            if (inventoryItem == null)  return;

            for (int y = 0; y < inventoryGrid.gridSizeHeight; y++)
            {
                for (int x = 0; x < inventoryGrid.gridSizeWidth; x++)
                {
                    //Check whether it is out of bounds
                    bool isInsideGrid = inventoryGrid.BoundryCheck(x,y,inventoryItem.Width,inventoryItem.Height);
                    if (isInsideGrid == false)  continue;

                    //Check whterther there is an empty site;
                    bool isEmpty = inventoryGrid.OverlapCheck( x, y, inventoryItem.Width, inventoryItem.Height );

                    if (isEmpty)
                    {
                        inventoryGrid.PlaceInventoryItem(inventoryItem, x, y);
                        return;
                    }
                }
            }

            Debug.LogError("There is no empty space in the inventory.£º" + inventoryItemdata.name);
            inventoryItem.gameObject.SetActive(false);
        }
    }

    private void GenerateInventoryItem() //Allow the inventory to choose between randomly generated items and directly generated items.
    {
        if (inventoryGrid.loadedFromSave) return;
        if(randomInventoryItemToGenerateData != null)
        {
            int generateAmount = Random.Range(minGenerateAmount, maxGenerateAmount+1);

            for (int i = 0; i < generateAmount; i++)
            {
                int randomIndex = Random.Range(0, randomInventoryItemToGenerateData.Length);

                InventoryItemData randomItemData = randomInventoryItemToGenerateData[randomIndex];

                PlaceInventoryItem(randomItemData);
            }
        }

        if (inventoryItemToGenerateData != null)
        {
            foreach (InventoryItemData inventoryitemData in inventoryItemToGenerateData)
            {
                PlaceInventoryItem(inventoryitemData);
            }
        }
    }

}
