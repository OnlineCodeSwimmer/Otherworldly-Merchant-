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

    private void Update()
    {
        
    }

    public void SetCustomCursor() //Change the cursor in game
    {
        Vector2 mousePoint = new Vector2(201, 201);
        Cursor.SetCursor(cursorTexture, mousePoint, CursorMode.Auto);
    }

    public void SetDefaultCursor()//Change the cursor in game
    {
        Vector2 mousePoint = new Vector2(201, 201);
        Cursor.SetCursor(null, mousePoint, CursorMode.Auto);
    }



}
