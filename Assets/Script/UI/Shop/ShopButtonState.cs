using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ShopButtonState : MonoBehaviour
{
    //Data
    public GunData gunData;

    //Base UI
    private Text buttonText;
    private Button buyButton;

    //State Varible
    private bool lastOwnedState;

    private void Awake()
    {
        buttonText = GetComponentInChildren<Text>();
        buyButton = GetComponentInChildren<Button>();
    }

  


    private void Update()
    {
        CheckPlayerOwnGun();
    }

    private void CheckPlayerOwnGun()
    {
        if (PlayerStateManager.instance == null) return;

        if (gunData == null) return;

        bool ownsGun = PlayerStateManager.instance.OwnsGun(gunData);

        if (ownsGun == lastOwnedState) return;


        lastOwnedState = ownsGun;

        RefreshButton(ownsGun);
    }

    private void RefreshButton(bool ownsGun)
    {
        buyButton.interactable = !ownsGun;

        if (buttonText != null)
        {
            buttonText.text = ownsGun ? "OWNED" : "BUY";
        }

    }

}
