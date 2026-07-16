using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.UI;
using static RandomDialogueGenerate;

public class CommuteDialogueItem : MonoBehaviour
{
    //Check Varible
    private bool isTrade;

    //Number Varible
    private float tradePrice;

    //Component
    private Image avatarImage;
    private Text nameText; 
    private Text messageText;
    private Text priceText;
    private List<ItemRequirement> requiredItems;
    private InventoryGrid storageInventoryGrid;
    private Button tradeButton;
    private void Awake()
    {
        avatarImage = GetComponent<Image>();
        nameText = transform.Find("Panel/Name").GetComponent<Text>();
        messageText = transform.Find("Panel/Message").GetComponent<Text>();
        priceText = transform.Find("Panel/Offer/Price").GetComponent<Text>();
        tradeButton = transform.Find("Trade Button").GetComponent<Button>();
    }
    private void Update()
    {
        RefreshTradeButton();
    }
    public void Setup(
        Sprite avatar,
        string nameText, 
        string messageText,
        float price,
        List<ItemRequirement> requiredItems,
        InventoryGrid storageInventoryGrid
        )
    {
        avatarImage.sprite = avatar;
        this.nameText.text = nameText;
        this.messageText.text = messageText;
        priceText.text = string.Format("{0}$",price);
        this.requiredItems = requiredItems;
        this.storageInventoryGrid = storageInventoryGrid;
        isTrade = false;
        tradePrice = price;


    }

    public void Trade()
    {
        if (isTrade) return;

        storageInventoryGrid.RemoveRequiredItems(requiredItems);

        PlayerStateManager.instance.balance += tradePrice;
        isTrade=true;

        foreach (CommuteDialogueItem dialogueItem in transform.parent.GetComponentsInChildren<CommuteDialogueItem>())
        {
            dialogueItem.RefreshTradeButton();
        }
    }

    public void RefreshTradeButton()
    {
        if(!gameObject.activeSelf) return;

        tradeButton.interactable=(!isTrade && storageInventoryGrid.HasRequiredItems(requiredItems));
    }
}
    