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
        if (entry.productType == ShopProductType.Equipment && amount > 0) return;

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
            int purchaseCount = entry.quantity / entry.productData.amountPerPurchase;
            totalPrice += entry.unitPrice * purchaseCount;
        }

        totalText.text = string.Format("Total: ${0}", totalPrice);
    }


    //Add Area
    public void AddGun(GunData gunData)
    {
        if (PlayerStateManager.instance.OwnsGun(gunData)) return;
        if (FindShoppingEntry(gunData) != null) return;
        AddProduct(gunData, ShopProductType.Equipment, gunData.price);
    }

    public void AddAmmo(AmmoData ammoData)
    {
        AddProduct(ammoData, ShopProductType.Ammo, ammoData.price);
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

        entry.quantity += productData.amountPerPurchase;
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


    //Purchase
    public void Purchase()
    {
        float totalPrice = 0;

        for (int i = 0; i < shoppingEntries.Count; i++)
        {
            ShoppingEntry entry = shoppingEntries[i];
            int purchaseCount = entry.quantity / entry.productData.amountPerPurchase;
            totalPrice += entry.unitPrice * purchaseCount;
        }

        if (PlayerStateManager.instance.balance < totalPrice) return;

        for (int i = 0; i < shoppingEntries.Count; i++)
        {
            ShoppingEntry entry = shoppingEntries[i];

            switch (entry.productType)
            {
                case ShopProductType.Ammo:
                    AmmoData ammoData = (AmmoData)entry.productData;
                    int receiveAmount = entry.quantity;
                    PlayerStateManager.instance.AddAmount(ammoData.ammoType, receiveAmount);
                    break;

                case ShopProductType.Equipment:
                    GunData gunData = (GunData)entry.productData;
                    PlayerStateManager.instance.ObtainGun(gunData);
                    break;
            }
        }

        PlayerStateManager.instance.balance -= totalPrice;
        ClearShoppingList();
    }
}
