using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class ComputerCloseButton : MonoBehaviour
{
    //Component
    private ComputerManager computerManager;

    //Text
    [Header("Text")]
    public Text Warning;
    public enum ButtonType
    {
        FirstPageButton,
        BankPageButton,
        CommutePageButton
    }

    public ButtonType buttonType;

    private void Awake()
    {
        computerManager= GetComponentInParent<ComputerManager>();
    }
    public void PreesedBuuton()
    {
        EventSystem.current.SetSelectedGameObject(null);
        switch (buttonType)
        {
            case ButtonType.FirstPageButton:
                computerManager.CloseAllWindows();
                computerManager.gameObject.SetActive(false);
                GameManager.instance.SetCustomCursor();
                Time.timeScale = 1;
                GameManager.instance.playerController.playerInput.Player.Enable();
                break;

            case ButtonType.BankPageButton:
                computerManager.CloseWindow("Computer Bank Page");
                computerManager.OpenWindow("Computer First Page");
                break;

            case ButtonType.CommutePageButton:
                computerManager.CloseWindow("Commute Page");
                computerManager.OpenWindow("Computer First Page");
                break;
        }
    }
}
