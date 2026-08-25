using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Playables;

public class PlayerController : MonoBehaviour
{
    public PlayerInput playerInput;

    //Character
    [Header("Character")]
    public float moveSpeed=3f;
    public int maxHealth=100;

    //Weapon Varible
    private bool holdWeapon;
    private bool isFire;

    //Move Parameter
    private Vector2 inputDirection;
    private Vector2 mousePosition;


    //Component
    private Animator animator;
    private Rigidbody2D rb;
    private Bleeding bleeding;
    public Gun gun;

    //Openable Object Variable
    public OpenableObject openableObject;
    private void Awake()
    {
        playerInput = new PlayerInput();
        rb = GetComponent<Rigidbody2D>();
        animator = GetComponent<Animator>();
        bleeding = GetComponent<Bleeding>();
        gun = GetComponent<Gun>();

    }

    private void Start()
    {
        GameManager.instance.SetCustomCursor();
        PlayerStateManager.instance.ReloadAllWeaponsOnSceneEnter();
        EquipWeapon(0);
    }


    private void Update()
    {
        InputCheck();
        FlipByMouse();
        AnimationUpdate();
        AutomaticFire();
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
    private void HoldWeapon(InputAction.CallbackContext context)
    {
        if (holdWeapon == false)
        {
            holdWeapon = true;
        }
        else
        {
            holdWeapon = false;
        }

        animator.SetBool("Hold Weapon", holdWeapon);

    }

    private void Fire()
    {
        Vector2 direction = (mousePosition - (Vector2)transform.position).normalized;
        gun.Shoot(direction);
    }

    private void Reload(InputAction.CallbackContext context)
    {
        if (!holdWeapon)
            return;

        gun.Reload();
    }
    private void FireStarted(InputAction.CallbackContext context)
    {
        if (!holdWeapon) return;

        isFire = true;
        Fire();
    }

    private void FireCanceled(InputAction.CallbackContext context)
    {
        isFire = false;
    }


    private void AutomaticFire()
    {
        if (!isFire) return;
        if (gun.currentGunData.fireMode !=FireMode.Automatic) return;

        Fire();
    }

    private void EquipWeapon(int index)
    {
        PlayerStateManager playerState = PlayerStateManager.instance;
        PlayerStateManager.WeaponInformation weapon =playerState.ownGun[index];
        playerState.weaponIndex = index;
        gun.Equip(weapon);

        animator.runtimeAnimatorController = weapon.gunData.animatorOverrideController;
    }

    private void SwitchWeapon(InputAction.CallbackContext context)
    {
        PlayerStateManager playerState =PlayerStateManager.instance;

        if (playerState.ownGun.Count <= 1) return;

        playerState.weaponIndex++;

        if (playerState.weaponIndex >= playerState.ownGun.Count)
        {
            playerState.weaponIndex = 0;
        }

        EquipWeapon(playerState.weaponIndex);
    }


    //Switch UI
    private void OpenBackpackInventory(InputAction.CallbackContext callBackContext)
    {
        playerInput.Player.Disable();
        InventoryManager.instance.playerInput.UI.Enable();
        GameManager.instance.SetDefaultCursor();
        InventoryManager.instance.CloseAllInventories();
        InventoryManager.instance.OpenBackpackInventory();

    }

    private void OpenObject(InputAction.CallbackContext callBackContext)
    {
        if (openableObject == null) return; 
        GameManager.instance.SetDefaultCursor();
        openableObject.OpenObject();
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
        playerInput.Player.HoldWeapon.started += HoldWeapon;
        playerInput.Player.Fire.started += FireStarted;
        playerInput.Player.Fire.canceled += FireCanceled;
        playerInput.Player.Reload.started += Reload;
        playerInput.Player.ToggleWeapon.started += SwitchWeapon;
    }



    private void UIInputUnsubscribe()
    {
        playerInput.Player.OpenBackpackInventory.started -= OpenBackpackInventory;
        playerInput.Player.OpenObject.started -= OpenObject;
        playerInput.Player.HoldWeapon.started -= HoldWeapon;
        playerInput.Player.Fire.started -= FireStarted;
        playerInput.Player.Fire.canceled -= FireCanceled;
        playerInput.Player.Reload.started -= Reload;
        playerInput.Player.ToggleWeapon.started-= SwitchWeapon;
    }


    //Tirgger Area
    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.CompareTag("Enemy"))
        {
            Enemy enemy = collision.GetComponent<Enemy>();

            if (PlayerStateManager.instance.health > 0)
            {
                PlayerStateManager.instance.health -= enemy.damage;
                bleeding.BloodSpawn(collision.transform);
            }
            else
            {
                PlayerStateManager.instance.health = 0;
            }
        }



    }

}
