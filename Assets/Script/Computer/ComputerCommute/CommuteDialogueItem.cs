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
    private float normalHeight;
    private float disapperAnimateTime=0.4f;

    //Component
    private Image avatarImage;
    private Text nameText; 
    private Text messageText;
    private Text priceText;
    private List<ItemRequirement> requiredItems;
    private InventoryGrid storageInventoryGrid;
    private Button tradeButton;
    private CanvasGroup canvasGroup;
    private LayoutElement layoutElement;
    private void Awake()
    {
        avatarImage = GetComponent<Image>();
        canvasGroup = GetComponent<CanvasGroup>();
        layoutElement = GetComponent<LayoutElement>();

        nameText = transform.Find("Panel/Name").GetComponent<Text>();
        messageText = transform.Find("Panel/Message").GetComponent<Text>();
        priceText = transform.Find("Panel/Offer/Price").GetComponent<Text>();
        tradeButton = transform.Find("Trade Button").GetComponent<Button>();

    }
    private void Start()
    {
        layoutElement.preferredHeight = 169.2117f;
        normalHeight = layoutElement.preferredHeight;
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
        //缺个时停动画方法


        avatarImage.sprite = avatar;
        this.nameText.text = nameText;
        this.messageText.text = messageText;
        priceText.text = string.Format("{0}$",price);
        this.requiredItems = requiredItems;
        this.storageInventoryGrid = storageInventoryGrid;
        tradePrice = price;
        isTrade = false;
        canvasGroup.alpha = 1f;
        canvasGroup.blocksRaycasts = true;
        layoutElement.preferredHeight = normalHeight;
        tradeButton.gameObject.SetActive(true);

    }

    public void Trade()
    {
        if (isTrade) return;

        storageInventoryGrid.RemoveRequiredItems(requiredItems);

        PlayerStateManager.instance.balance += tradePrice;
        isTrade=true;

        tradeButton.gameObject.SetActive(false);
        canvasGroup.alpha = 0;
        canvasGroup.blocksRaycasts = false;
        StartCoroutine(DialogueDisapperAnimate());
    }

    private IEnumerator DialogueDisapperAnimate()
    {
        float elapsedTime = 0f;

        while(elapsedTime < disapperAnimateTime)
        {
            elapsedTime += Time.unscaledDeltaTime;
            float progress = Mathf.Clamp01((elapsedTime / disapperAnimateTime));
            layoutElement.preferredHeight =  Mathf.Lerp(normalHeight, 0f, progress);
            yield return null;
        }

        gameObject.SetActive(false);
        transform.SetParent(PoolManager.instance.transform);
    }


    public void RefreshTradeButton()
    {
        if(!gameObject.activeSelf) return;

        tradeButton.interactable=(!isTrade && storageInventoryGrid.HasRequiredItems(requiredItems));
    }


}
    