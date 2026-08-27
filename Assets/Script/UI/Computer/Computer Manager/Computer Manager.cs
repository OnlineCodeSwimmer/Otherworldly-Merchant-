using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ComputerManager : MonoBehaviour
{
    //Windows
    [Header("Windows")]
    public GameObject[] windows;

    //Input Variable
    public PlayerInput playerInput;

    


    private void Awake()
    {
        playerInput = new PlayerInput();
    }

    private void OnEnable()
    {
        playerInput.UI.Enable();

    }

    private void OnDisable()
    {
        playerInput.UI.Disable();
    }

    //Windows UI Open and Close
    public void OpenWindow(string name)
    {

        foreach (GameObject window in windows)
        {
            if (window.name == name)
            {
                window.SetActive(true);
                return;
            }
        }

        Debug.LogError("Inventory window not found: " + name);

    }

    public void CloseWindow(string name)
    {

        foreach (GameObject window in windows)
        {
            if (window.name == name)
            {
                window.SetActive(false);
                return;
            }
        }

        Debug.LogError("Inventory window not found: " + name);

    }
    public void CloseAllWindows()
    {
        foreach (GameObject window in windows)
        {
            if (window != null)
            {
                window.SetActive(false);
            }
        }

    }


}
