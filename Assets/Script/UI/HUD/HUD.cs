using System.Collections;
using System.Collections.Generic;
using System.Net.NetworkInformation;
using UnityEditor.EditorTools;
using UnityEngine;
using UnityEngine.InputSystem.iOS;
using UnityEngine.UI;

public class HUD : MonoBehaviour
{
    public enum InfomationType
    {
        InventoryWaring,
        PlayerHealth
    }

    public InfomationType type;
    private Text uiText;
    private float lifeTimer;


    private void OnEnable()
    {
        uiText = GetComponent<Text>();
        Init();
    }
    private void LateUpdate()
    {
        DisaplayHUD();  
    }

    private void Init()
    {
        switch(type)
        {
            case InfomationType.InventoryWaring:
                lifeTimer = 2f;
                break;
        }
    }
    private void DisaplayHUD()
    {
        switch (type)
        {
            case InfomationType.InventoryWaring:
                if (!InventoryManager.instance.mainInventoryUI.activeSelf)
                {
                    gameObject.SetActive(false);
                    transform.SetParent(PoolManager.instance.transform);


                }

                if (lifeTimer > 0)
                {
                    lifeTimer -= Time.deltaTime;
                    uiText.text = "Please put down the item in your hand.";
                    uiText.color = Color.red;
                }
                else
                {
                    gameObject.SetActive(false);
                    transform.SetParent(PoolManager.instance.transform);
                }

                break;

            case InfomationType.PlayerHealth:
                uiText.text = string.Format("{0}",PlayerStateManager.instance.health);
                break;
        }
    }
}
