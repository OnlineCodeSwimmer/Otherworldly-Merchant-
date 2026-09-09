using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShoppingProductData : ScriptableObject
{
    //Shopping Information
    [Header("Shopping Information")]
    public Vector2 shoppingListItemIconSize;
    public Sprite productIcon;
    public float price;
    public int amountPerPurchase = 1;
}
