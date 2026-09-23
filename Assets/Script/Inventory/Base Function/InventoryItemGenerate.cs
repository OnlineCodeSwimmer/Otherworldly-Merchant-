using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using static InventoryItemData;

public class InventoryItemGenerate : MonoBehaviour
{

    //Generate Varible
    [Header("Random Amount")]
    public int minGenerateAmount;
    public int maxGenerateAmount;

    [Header("Quality Probability")]
    public float commonProbability = 70f;
    public float rareProbability = 25f;
    public float legendaryProbability = 5f;


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

            if (inventoryItem == null) return;

            for (int y = 0; y < inventoryGrid.gridSizeHeight; y++)
            {
                for (int x = 0; x < inventoryGrid.gridSizeWidth; x++)
                {
                    //Check whether it is out of bounds
                    bool isInsideGrid = inventoryGrid.BoundryCheck(x, y, inventoryItem.Width, inventoryItem.Height);
                    if (isInsideGrid == false) continue;

                    //Check whterther there is an empty site;
                    bool isEmpty = inventoryGrid.OverlapCheck(x, y, inventoryItem.Width, inventoryItem.Height);

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
        if (randomInventoryItemToGenerateData != null)
        {
            int generateAmount = Random.Range(minGenerateAmount, maxGenerateAmount + 1);

            for (int i = 0; i < generateAmount; i++)
            {
                ItemQuality randomQuality = GetRandomQuality();
                InventoryItemData randomItemData = GetRandomItemByQuality(randomQuality);
                PlaceInventoryItem(randomItemData);
            }
        }



        //Direct generate inventoryItem
        if (inventoryItemToGenerateData != null)
        {
            foreach (InventoryItemData inventoryitemData in inventoryItemToGenerateData)
            {
                PlaceInventoryItem(inventoryitemData);
            }
        }
    }


    //Item probability calculation area
    private ItemQuality GetRandomQuality()
    {
        float randomValue = Random.Range(0f, 100f);

        switch (randomValue)
        {
            case float value when value <= commonProbability:
                return ItemQuality.Common;

            case float value when value <= commonProbability+rareProbability:
                return ItemQuality.Rare;

            default:
                return ItemQuality.Legendary;
        }
    }


    private InventoryItemData GetRandomItemByQuality(ItemQuality itemQuality)
    {
        List<InventoryItemData> qualityItems = new List<InventoryItemData>();

        for (int i = 0; i < randomInventoryItemToGenerateData.Length; i++)
        {
            InventoryItemData itemData = randomInventoryItemToGenerateData[i];

            if (itemData.itemQuality == itemQuality)
            {
                qualityItems.Add(itemData);
            }
        }

        int randomIndex = Random.Range(0, qualityItems.Count);
        return qualityItems[randomIndex];
    }


}
