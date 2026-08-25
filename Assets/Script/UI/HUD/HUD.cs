using System.Collections;
using System.Collections.Generic;
using System.Net.NetworkInformation;
using UnityEditor.EditorTools;
using UnityEngine;
using UnityEngine.InputSystem.iOS;
using UnityEngine.UI;

public class HUD : MonoBehaviour
{
    public enum InformationType
    {
        InventoryWaring,
        PlayerHealth,
        GunAmmo,
        GunSprite,
        ReloadIcon,
        HintE
    }


    public InformationType type;
    public Vector2 offset;
    private Text uiText;
    private Image uiImage;
    private float lifeTimer;

    //Component
    private Camera mainCamera;


    private void Awake()
    {
        uiText = GetComponent<Text>();
        uiImage = GetComponent<Image>();
    }
    private void OnEnable()
    {
        Init();
    }



    private void FixedUpdate()
    {
        HUDMove();
    }



    private void LateUpdate()
    {
        DisaplayHUD();  
    }

    private void Init()
    {
        switch(type)
        {
            case InformationType.InventoryWaring:
                lifeTimer = 2f;
                break;
        }
    }
    private void DisaplayHUD()
    {
        Gun gun = GameManager.instance.playerController.gun;
        GunData currentGunData = GameManager.instance.playerController.gun.currentGunData;


        switch (type)
        {
            case InformationType.InventoryWaring:
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

            case InformationType.PlayerHealth:
                uiText.text = string.Format("{0}",PlayerStateManager.instance.health);
                break;

            case InformationType.GunSprite:
                uiImage.sprite = currentGunData.gunIcon;
                uiImage.rectTransform.sizeDelta = currentGunData.iconSize;
                break;

            case InformationType.GunAmmo:
                int gunAmmo = gun.currentAmmo;
                int reserveAmmo = PlayerStateManager.instance.GetAmmoAmount(gun.currentGunData.ammoType);
                uiText.text =string.Format("{0}/{1}", gunAmmo, reserveAmmo);
                break;

            case InformationType.ReloadIcon:
                uiImage.enabled = gun.isReloding;
                break;

            case InformationType.HintE:
                PlayerController playerController = GameManager.instance.playerController;

                uiText.enabled= playerController.openableObject!=null;
                break;
        }
    }


    private void HUDMove()
    {
        switch(type)
        {
            case InformationType.HintE:
                PlayerController playerController = GameManager.instance.playerController;
                Vector2 playerPosition = playerController.transform.position;

                uiText.transform.position = Camera.main.WorldToScreenPoint(playerPosition + offset);
                break;
        }
    }
}
