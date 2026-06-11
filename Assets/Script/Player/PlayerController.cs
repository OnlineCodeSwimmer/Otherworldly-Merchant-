using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    public PlayerInput playerInput;
    public Texture2D cursorTexture;
    [Header("Move Parameter")]
    private Vector2 inputDireciton;
    private Vector2 mousePosition;
    private float moveSpeed=3;
    [Header("Component")]
    private Animator animator;
    private Rigidbody2D rb;
    private void Awake()
    {
        playerInput=new PlayerInput();
        rb=GetComponent<Rigidbody2D>();
        animator = GetComponent<Animator>();
        SetCustomCursor();
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
        playerInput.Enable();
    }
    private void OnDisable()
    {
        playerInput.Disable();
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


        private void InputCheck()
    {
        inputDireciton=playerInput.Player.Move.ReadValue<Vector2>().normalized;
        mousePosition = Camera.main.ScreenToWorldPoint(Mouse.current.position.ReadValue());
    }

    private void SetCustomCursor() //Change the cursor in game
    {
        Vector2 mousePoint = new Vector2(201, 201);
        Cursor.SetCursor(cursorTexture, mousePoint, CursorMode.Auto);
    }
}
