using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.UI;
public class ComputerSelectButton : MonoBehaviour
{
    public enum ButtonType
    {
        Repay
    
    }

    public ButtonType buttonType;


    //Text
    [Header("Text")]
    public Text Warning;


    private void Awake()
    {
        Warning.gameObject.SetActive(false);
    }

    public void PressButton()
    {
        switch (buttonType)
        {
            case ButtonType.Repay:
                float bankBalance = PlayerStateManager.instance.balance;
                float debt=PlayerStateManager.instance.debt;

                if(bankBalance < debt ) 
                {
                    Warning.gameObject.SetActive (true);
                    StartCoroutine(CloseTimer());
                }
                else
                {
                    bankBalance = bankBalance - debt;
                    PlayerStateManager.instance.balance = bankBalance;
                    PlayerStateManager.instance.debt = 0;
                }
                break;
        }

    }
    private IEnumerator CloseTimer()
    {
       yield return new WaitForSeconds(1.5f);
       Warning.gameObject.SetActive(false);
    }
}
