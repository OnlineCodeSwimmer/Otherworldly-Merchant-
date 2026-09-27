using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "New Commute Dialogue",menuName = "Data/Commute/Dialogue")]
public class CommuteDialogueData : ScriptableObject
{
    [TextArea]
    public string messageText;

    //Demand
    [Header("Demand")]
    public List<ItemRequirement> requiredItems = new List<ItemRequirement>();

    [Header("Reward")]
    public float minPrice;
    public float maxPrice;


    [System.Serializable]
    public class ItemRequirement
    {
        public InventoryItemData inventoryItemData;
        public int amount;
    }
}