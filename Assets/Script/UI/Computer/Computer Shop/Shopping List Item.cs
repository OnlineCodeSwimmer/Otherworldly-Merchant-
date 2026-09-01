using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ShoppingListItem : MonoBehaviour
{
    //Shopping Information
    [Header("Shopping Infromation UI Component")]
    public Image productIcon;
    public Text quantityText;
    public Text priceText;
    private ShoppingList shoppingList;
    private ShoppingProductData productData;

    public void Set(ShoppingList shoppingList, ShoppingProductData productData)
    {
        this.shoppingList = shoppingList;
        this.productData = productData;
        productIcon.sprite = productData.productIcon;
        productIcon.rectTransform.sizeDelta = productData.shoppingListItemIconSize;
        ;
    }

    public void Refresh(float quantity)
    {
        quantityText.text = string.Format("x{0}", quantity);
        float subtotal = productData.price * quantity;
        priceText.text = string.Format("{0}$", subtotal);
    }

    public void AddOne()
    {
        shoppingList.ChangeQuantity(productData, 1);
    }

    public void SubtractOne()
    {
        shoppingList.ChangeQuantity(productData, -1);
    }
}
