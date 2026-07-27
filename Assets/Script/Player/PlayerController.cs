using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    public PlayerInput playerInput;

    //Character
    [Header("Character")]
    public float health;
    public float moveSpeed = 3;


    //Weapon Varible
    private bool HoldWepon;
    private float fireInterval=0.25f;
    private bool  isFireInterval;

    //Move Parameter
    private Vector2 inputDirection;
    private Vector2 mousePosition;


    //Component
    private Animator animator;
    private Rigidbody2D rb;
    Transform  muzzle;

    //Openable Object Variable
    public OpenableObject openableObject;
    private void Awake()
    {
        playerInput=new PlayerInput();
        rb=GetComponent<Rigidbody2D>();
        animator = GetComponent<Animator>();
        muzzle=transform.Find("Muzzle").GetComponent<Transform>();
    }

    private void Start()
    {
        GameManager.instance.SetCustomCursor();
    }


    private void Update()
    {
        InputCheck();
        FlipByMouse();
        AnimationUpdate();
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
        rb.velocity = inputDirection * moveSpeed;


    }

    private void AnimationUpdate()
    {
        animator.SetFloat("VelocityX", Mathf.Abs(rb.velocity.x));
        animator.SetFloat("VelocityY", Mathf.Abs(rb.velocity.y));
    }
    private void FlipByMouse()
    {
        Vector2 direction = mousePosition - (Vector2)transform.position;
        transform.up = direction;
    }





    //Weapon
    private void ToggleWeapon(InputAction.CallbackContext context)
    {
       if(HoldWepon==false)
          {
              HoldWepon = true;
          }
       else
          {
            HoldWepon=false;
          }

        animator.SetBool("Hold Weapon", HoldWepon);

    }

    private void Fire(InputAction.CallbackContext callBackContext)
    {
        if (HoldWepon == false) return;
        if (isFireInterval) return;

        Vector2 direction=(mousePosition - (Vector2)transform.position).normalized;
        GameObject bullet = PoolManager.instance.Get("Bullet");
        bullet.GetComponent<Bullet>().damage = 1;
        bullet.transform.position = muzzle.position; 
        bullet.GetComponent<Bullet>().SetSpeed(direction);
        isFireInterval = true;
        StartCoroutine(FireCooldown());
    }
    private IEnumerator FireCooldown()
    {
        yield return new WaitForSeconds(fireInterval);
        isFireInterval = false;
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

    private void OpenObject(InputAction.CallbackContext callBackContext)
    {
        if (openableObject == null) return; 
        Time.timeScale = 0;
        GameManager.instance.SetDefaultCursor();
        openableObject.GetComponent<OpenableObject>().OpenObject();


    }

    


    //InputArea
    private void InputCheck()
    {
        inputDirection = playerInput.Player.Move.ReadValue<Vector2>().normalized;
        mousePosition = Camera.main.ScreenToWorldPoint(Mouse.current.position.ReadValue());
    }

    private void UIInputSubscribe()
    {
        playerInput.Player.OpenBackpackInventory.started += OpenBackpackInventory;
        playerInput.Player.OpenObject.started += OpenObject;
        playerInput.Player.ToggleWepon.started += ToggleWeapon;
        playerInput.Player.Fire.started += Fire;
    }



    private void UIInputUnsubscribe()
    {
        playerInput.Player.OpenBackpackInventory.started -= OpenBackpackInventory;
        playerInput.Player.OpenObject.started -= OpenObject;
        playerInput.Player.ToggleWepon.started -= ToggleWeapon;
        playerInput.Player.Fire.started -= Fire;
    }


}
