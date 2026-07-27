using System.Collections;
using System.Collections.Generic;
using System.Net.NetworkInformation;
using UnityEngine;

public class RandomDialogueGenerate : MonoBehaviour
{
    //Enum for price perecision checking 
    public enum PricePrecision
    {
        Integer,  
        OneDecimal,
        TwoDecimals
    }


    //Struct
    //Charcter name and avater struct
    [System.Serializable]
    public struct CharacterOption
    {
        public string characterName;
        public Sprite avatar;
    }
    //Requirement struct
    [System.Serializable]
    public struct ItemRequirement
    {
        public InventoryItemData inventoryItemData;
        public int amount;
    }




    //Message struct
    [System.Serializable]
    public struct MessageOption
    {
        public string messageText;
        public List<ItemRequirement> requiredItems;
        public float minPrice;
        public float maxPrice;
    }

    //InventoryGrid
    public InventoryGrid storageInventoryGrid;

    //Dialogue Number
    [Header("Dialogute Number")]
    public int dialogueCount = 3;



    //List
    //Character name and avatar List
    [Header("Character Name and Avatar")]
    public List<CharacterOption> characterOptions = new List<CharacterOption>();

    //Message list
    [Header("Message")]
    public List<MessageOption> messageOption = new List<MessageOption>();



    private void Awake()
    {
        
    }





    private void Start()
    {
        ClearAllDialogues();
        GenerateDialogue();
    }

    

    private void GenerateDialogue()
    {
        for(int i = 0; i < dialogueCount; i++)
        {
            
            CharacterOption randomCharacterOption = characterOptions[Random.Range(0, characterOptions.Count)];
            MessageOption randomMessageOption = messageOption[Random.Range(0, messageOption.Count)];

            //Generate price
            int minCents = (int)(randomMessageOption.minPrice * 100f);
            int maxCents = (int)(randomMessageOption.maxPrice * 100f);
            float randomPrice = Random.Range(minCents, maxCents + 1) / 100f;

            CommuteDialogueItem dialogueItem = PoolManager.instance.Get("Commute Dialoge Prefab").GetComponent<CommuteDialogueItem>();
            dialogueItem.transform.SetParent(transform, false);
            dialogueItem.Setup(
                randomCharacterOption.avatar, 
                randomCharacterOption.characterName, 
                randomMessageOption.messageText, 
                randomPrice,
                randomMessageOption.requiredItems,
                storageInventoryGrid
                );
        }
    }


    private void ClearAllDialogues()
    {
        for (int i = transform.childCount - 1; i >= 0; i--)
        {
            GameObject dialogue =transform.GetChild(i).gameObject;
            dialogue.SetActive(false);
            dialogue.transform.SetParent(PoolManager.instance.transform);

        }
    }

}
