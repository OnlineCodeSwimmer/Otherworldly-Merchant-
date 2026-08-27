using Microsoft.Unity.VisualStudio.Editor;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ComputerUIPackge: MonoBehaviour
{
    public enum UIType
    {
        BankBalance,
        BankDebt
    }

    public UIType uiType;
    private Text uiText;


    private void Awake()
    {
        uiText=GetComponent<Text>();
    }
    private void Update()
    {
        UIDisplay();
    }

    private void UIDisplay()
    {
        switch (uiType)
        {
            case UIType.BankBalance:
                float balance = PlayerStateManager.instance.balance;
                uiText.text = string.Format("Balance: ${0:F2}", balance);
                break;

            case UIType.BankDebt:
                float debt = PlayerStateManager.instance.debt;
                uiText.text = string.Format("Debt: ${0:F2}", debt);
                break;
        }
    }
}
