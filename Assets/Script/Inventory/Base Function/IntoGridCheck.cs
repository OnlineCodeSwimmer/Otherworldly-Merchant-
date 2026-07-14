
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

[RequireComponent(typeof(InventoryGrid))]
public class IntoGridCheck : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{

    InventoryGrid inventoryGrid;

    public void OnPointerEnter(PointerEventData evenData)
    {
        InventoryManager.instance.selectedInventoryGrid = inventoryGrid;
    }
    public void OnPointerExit(PointerEventData eventData)
    {
        InventoryManager.instance.selectedInventoryGrid = null;
    }

    private void Awake()
    {
        inventoryGrid = GetComponent<InventoryGrid>();
    }




}
