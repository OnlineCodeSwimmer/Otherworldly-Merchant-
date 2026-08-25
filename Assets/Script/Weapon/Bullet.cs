using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    //Character
    [HideInInspector]public float currentDamage;
    [HideInInspector] public Vector2 moveDirection;

    //Component
    private Rigidbody2D rb;
    private TrailRenderer trailRenderer;




    private void Update()
    {
        FarToDestory();
    }


    private void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        trailRenderer= GetComponent<TrailRenderer>();   
    }
    private void Start()
    {
        trailRenderer.widthMultiplier = 0.5f; 
    }

    public void Init(Vector2 direction, float speed, float damage)
    {
        currentDamage = damage;
        moveDirection = direction;
        rb.velocity = speed*direction;
        transform.right = direction;
    }



    private void FarToDestory() // Bullet auto-destroys after traveling a certain distance from the player without hitting any target
    {
        float distanceX = Mathf.Abs(GameManager.instance.playerController.transform.position.x - transform.position.x);
        float distanceY = Mathf.Abs(GameManager.instance.playerController.transform.position.y - transform.position.y);
        GunData cunrrentGunData = GameManager.instance.playerController.gun.currentGunData;
        if (distanceX > cunrrentGunData.fireDistance || distanceY > cunrrentGunData.fireDistance)
        {
            Destory();
        }

    }



    private void OnTriggerEnter2D(Collider2D collision)
    {
        Destory();
    }
    private void Destory()
    {
        GameObject bulletExplosion = PoolManager.instance.Get("GunBulletExplosion");
        bulletExplosion.transform.position = transform.position;

        rb.velocity = Vector2.zero;
        gameObject.SetActive(false);
        trailRenderer.Clear();
        gameObject.transform.SetParent(PoolManager.instance.transform);

    }



}
