using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShoppingProductData : ScriptableObject
{
    //Shopping Information
    [Header("Shopping Information")]
    public Vector2 shoppingListItemIconSize;
    public Vector2 shoppinProductItemIconSize;
    public Sprite productIcon;
    public float price;
}
