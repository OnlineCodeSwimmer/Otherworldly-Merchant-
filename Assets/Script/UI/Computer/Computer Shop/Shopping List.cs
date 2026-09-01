using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;

public class ShoppingList : MonoBehaviour
{
    //Data
    private class ShoppingEntry
    {
        public ShoppingProductData productData;
        public ShopProductType productType;
        public float unitPrice;
        public int quantity;
        public ShoppingListItem shoppingListItem;
    }

    private List<ShoppingEntry> shoppingEntries = new List<ShoppingEntry>();

    //UI
    [Header("UI")]
    public Text totalText;
    public GameObject shoppingItemList;

    private void OnEnable()
    {
        ClearShoppingList();
    }


    public void ChangeQuantity(ShoppingProductData productData, int amount)
    {
        ShoppingEntry entry = FindShoppingEntry(productData);

        if (entry == null ) return;


        entry.quantity += amount;

        ShoppingListItem shoppingListItem = entry.shoppingListItem;

        if (entry.quantity <= 0)
        {

            shoppingListItem.gameObject.SetActive(false);
            shoppingListItem.transform.SetParent(PoolManager.instance.transform);
            shoppingEntries.Remove(entry);
        }

        RefreshShoppingList();
    }

    private ShoppingEntry FindShoppingEntry(ShoppingProductData productData)
    {
        for (int i = 0; i < shoppingEntries.Count; i++)
        {
            if (shoppingEntries[i].productData == productData)
                return shoppingEntries[i];
        }

        return null;
    }

    private void RefreshShoppingList()
    {
        float totalPrice = 0;

        for (int i = 0; i < shoppingEntries.Count; i++)
        {
            ShoppingEntry entry = shoppingEntries[i];

            entry.shoppingListItem.Refresh(entry.quantity);
            totalPrice += entry.unitPrice * entry.quantity;
        }

        totalText.text = string.Format("Total: {0}$", totalPrice);
    }


    //Add Area
    public void AddGun(GunData gunData)
    {
        AddProduct(gunData, ShopProductType.Equipment, gunData.price);
    }


    private void AddProduct(ShoppingProductData productData, ShopProductType productType, float unitPrice)
    {
        ShoppingEntry entry = FindShoppingEntry(productData);

        if (entry == null)
        {
            GameObject itemObject = PoolManager.instance.Get("Shopping List Item");
            itemObject.transform.SetParent(shoppingItemList.transform);

            ShoppingListItem shoppingListItem = itemObject.GetComponent<ShoppingListItem>();
            shoppingListItem.Set(this, productData);

            entry = new ShoppingEntry();
            entry.productData = productData;
            entry.productType = productType;
            entry.unitPrice = unitPrice;
            entry.quantity = 0;
            entry.shoppingListItem = shoppingListItem;

            shoppingEntries.Add(entry);
        }

        entry.quantity++;
        RefreshShoppingList();

    }

    public void ClearShoppingList()
    {
        for (int i = 0; i < shoppingEntries.Count; i++)
        {
            ShoppingListItem shoppingListItem = shoppingEntries[i].shoppingListItem;

            shoppingListItem.transform.SetParent(PoolManager.instance.transform, false);
            shoppingListItem.gameObject.SetActive(false);
        }

        shoppingEntries.Clear();
        RefreshShoppingList();
    }
}
