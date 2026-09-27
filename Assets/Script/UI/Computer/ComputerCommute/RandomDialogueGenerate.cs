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


    //InventoryGrid
    public InventoryGrid storageInventoryGrid;

    //Dialogue Number
    [Header("Dialogute Number")]
    public int dialogueCount = 3;



    //List
    //Character name and avatar List
    [Header("Character Name and Avatar")]
    public List<CommuteCharacterData> characterOptions = new List<CommuteCharacterData>();

    //Message list
    [Header("Message")]
    public List<CommuteDialogueData> messageOption = new List<CommuteDialogueData>();

    //Prefab
    [Header("Prefab")]
    public GameObject CommuniteDialoguePrefab;


    private void Awake()
    {
        
    }





    private void Start()
    {
        FindComponent();
        ClearAllDialogues();
        GenerateDialogue();
    }

    

    private void GenerateDialogue()
    {
        for(int i = 0; i < dialogueCount; i++)
        {

            CommuteCharacterData randomCharacterOption = characterOptions[Random.Range(0, characterOptions.Count)];
            CommuteDialogueData randomMessageOption = messageOption[Random.Range(0, messageOption.Count)];

            //Generate price
            int minCents = (int)(randomMessageOption.minPrice * 100f);
            int maxCents = (int)(randomMessageOption.maxPrice * 100f);
            float randomPrice = Random.Range(minCents, maxCents + 1) / 100f;

            CommuteDialogueItem dialogueItem = PoolManager.instance.Get(CommuniteDialoguePrefab).GetComponent<CommuteDialogueItem>();
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

    private void FindComponent()
    {
        InventoryManager inventoryManager= InventoryManager.instance;
        storageInventoryGrid = inventoryManager.transform.Find("Inventory UI/Storage Inventory/Storage Inventory Grid").GetComponent<InventoryGrid>();

    }

}
