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

    public void Refresh(int quantity)
    {
        quantityText.text = string.Format("x{0}", quantity);
        int purchaseCount = quantity / productData.amountPerPurchase;
        float subtotal = productData.price * purchaseCount;
        priceText.text = string.Format("${0}", subtotal);
    }

    public void Add()
    {
        shoppingList.ChangeQuantity(productData, productData.amountPerPurchase);
    }

    public void Subtract()
    {
        shoppingList.ChangeQuantity(productData, -productData.amountPerPurchase);
    }
}
