using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    //Bullet Character 
    public float damage;
    private float speed=30f;


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
        trailRenderer.widthMultiplier = 0.3f; 
    }

    public void SetSpeed(Vector2 direction)
    {
        rb.velocity = speed*direction;
        transform.right = direction;
    }



    private void FarToDestory() // Bullet auto-destroys after traveling a certain distance from the player without hitting any target
    {
        float distanceX = Mathf.Abs(GameManager.instance.playerController.transform.position.x - transform.position.x);
        float distanceY = Mathf.Abs(GameManager.instance.playerController.transform.position.y - transform.position.y);
        if (distanceX > 30 || distanceY > 30)
        {
            gameObject.SetActive(false);
            trailRenderer.Clear();
            gameObject.transform.SetParent(PoolManager.instance.transform);
        }

    }
}
