using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class UIButton : MonoBehaviour
{
    public enum ButtonType
    {
        TeleportClinic
    }

    public ButtonType buttonType;

    public void ButtonPress()
    {
        switch (buttonType)
        {
            case ButtonType.TeleportClinic:
                SceneManager.LoadScene("Clinic");
                break;
        
        
        }

    }
}
