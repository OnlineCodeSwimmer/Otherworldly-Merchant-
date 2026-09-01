using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "New Item Data", menuName = "Data/Item Data")]
public class InventoryItemData : ScriptableObject
{
    [Header("Size")]
    public int sizeWidth = 1;
    public int sizeHeight = 1;

    [Header("Basic Information")]
    public int ItemID;
    public Sprite itemIcon;
    public string itemName;
    public string itemDescription;
    public Color itemNameColor;

}
