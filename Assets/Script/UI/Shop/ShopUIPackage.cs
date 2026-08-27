using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ShopUIPackage : MonoBehaviour
{
    public enum UIType
    {
        Balance
    }

    public UIType uiType;
    private Text uiText;

    private void Awake()
    {
        uiText = GetComponent<Text>();
    }
    private void Update()
    {
        UIDisplay();
    }

    private void UIDisplay()
    {
        switch (uiType)
        {
            case UIType.Balance:
                float balance = PlayerStateManager.instance.balance;
                uiText.text = string.Format("Balance: ${0:F2}", balance);
                break;

        }
    }
}
