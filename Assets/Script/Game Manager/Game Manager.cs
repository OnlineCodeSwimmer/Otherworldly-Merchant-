using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager instance;


    //Component
    [Header("Component")]
    public PlayerController playerController;

    //UI
    [Header("UI")]
    public ComputerManager computerManager;

    //Cursor Variable
    public Texture2D cursorTexture;


    private void Awake()
    {
        instance = this; 
    }


    public void SetCustomCursor() //Change the cursor in game
    {
        if (cursorTexture == null)
        {
            SetDefaultCursor();
            return;
        }

        Vector2 hotspot = new Vector2(cursorTexture.width / 2f, cursorTexture.height / 2f);
        Cursor.SetCursor(cursorTexture, hotspot, CursorMode.Auto);
    }

    public void SetDefaultCursor()//Change the cursor in game
    {
        Cursor.SetCursor(null, Vector2.zero, CursorMode.Auto);
    }



}
