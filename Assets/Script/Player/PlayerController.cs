using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    public PlayerInput playerInput;
    //Move Parameter
    private Vector2 inputDireciton;
    private Vector2 mousePosition;
    private float moveSpeed=3;

    //Component
    private Animator animator;
    private Rigidbody2D rb;

    //Openable Object Variable
    public OpenableObject openableObject;
    private void Awake()
    {
        playerInput=new PlayerInput();
        rb=GetComponent<Rigidbody2D>();
        animator = GetComponent<Animator>();
    }

    private void Start()
    {
        GameManager.instance.SetCustomCursor();
    }


    private void Update()
    {
        InputCheck();
        FlipByMouse();
    }

    private void FixedUpdate()
    {
        Move();
    }
    private void OnEnable()
    {
        playerInput.Player.Enable();
        UIInputSubscribe();
    }
    private void OnDisable()
    {
        playerInput.Player.Disable();
        UIInputUnsubscribe();
    }


    private void Move()
    {
        rb.velocity = inputDireciton * moveSpeed;
        animator.SetFloat("VelocityX", Mathf.Abs(rb.velocity.x));
        animator.SetFloat("VelocityY", Mathf.Abs(rb.velocity.y));

    }
    private void FlipByMouse()
    {
        Vector2 direction = mousePosition - (Vector2)transform.position;
        float angle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg-90f;
        transform.rotation = Quaternion.Euler(0, 0, angle);
    }






    //Switch UI
    private void OpenBackpackInventory(InputAction.CallbackContext callBackContext)
    {
        playerInput.Player.Disable();
        InventoryManager.instance.playerInput.UI.Enable();
        GameManager.instance.SetDefaultCursor();
        InventoryManager.instance.CloseAllInventories();
        InventoryManager.instance.OpenInventoryWindow("Backpack Inventory");

    }

    private void OpenObjectInvetory(InputAction.CallbackContext callBackContext)
    {
        if (openableObject == null) return; 
        playerInput.Player.Disable();
        InventoryManager.instance.playerInput.UI.Enable();
        GameManager.instance.SetDefaultCursor();
        InventoryManager.instance.CloseAllInventories();
        openableObject.GetComponent<OpenableObject>().OpenInventory();


    }


    //InputArea
    private void InputCheck()
    {
        inputDireciton = playerInput.Player.Move.ReadValue<Vector2>().normalized;
        mousePosition = Camera.main.ScreenToWorldPoint(Mouse.current.position.ReadValue());
    }

    private void UIInputSubscribe()
    {
        playerInput.Player.OpenBackpackInventory.started += OpenBackpackInventory;
        playerInput.Player.OpenObjectInventory.started += OpenObjectInvetory;
    }

    private void UIInputUnsubscribe()
    {
        playerInput.Player.OpenBackpackInventory.started -= OpenBackpackInventory;
        playerInput.Player.OpenObjectInventory.started -= OpenObjectInvetory;


    }
}
