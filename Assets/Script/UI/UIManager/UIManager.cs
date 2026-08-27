using UnityEngine.InputSystem;
using UnityEngine;

public class UIManager : MonoBehaviour
{
    public static UIManager instance;


    //UI Windows
    public GameObject[] windows;

    //Input Variable
    public PlayerInput playerInput;





    private void Awake()
    {
        instance = this;
        playerInput = new PlayerInput();
    }


    private void OnEnable()
    {
        UIInputSubscribe();
    }


    private void OnDisable()
    {
        UIInputUnsubscribe();
        playerInput.UI.Disable();
    }
    private void PressEscKey(InputAction.CallbackContext context)
    {
        CloseAllWindow();
    }

    public void CloseAllWindow()
    {
        PlayerController playerController = GameManager.instance.playerController;

        foreach (GameObject window in windows) 
        { 
            window.SetActive(false);
        }

        playerInput.UI.Disable();
        playerController.playerInput.Player.Enable();

        GameManager.instance.SetCustomCursor();
    }


    //Input Area
    private void UIInputSubscribe()
    {
        playerInput.UI.CloseWindow.started += PressEscKey;
    }

    private void UIInputUnsubscribe()
    {
        playerInput.UI.CloseWindow.started -= PressEscKey;
    }
}
