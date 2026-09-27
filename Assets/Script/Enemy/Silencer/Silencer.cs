using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Silencer : Enemy
{
    protected override void OnEnable()
    {
        base.OnEnable();
        currentState = EnemyState.Idle;
    }

    protected override void UpdateState()
    {
        if (currentState == EnemyState.Chase)
        {
            return;
        }

        Vector2 playerPosition =  GameManager.instance.playerController.transform.position;
        Vector2 playerDirection = playerPosition - (Vector2)transform.position;
        float distanceSqrMagnitude =playerDirection.sqrMagnitude;

        bool playerInVisionDistance = distanceSqrMagnitude < enemyData.visionDistance * enemyData.visionDistance;

        if (playerInVisionDistance && CanSeePlayer(playerPosition))
        {
            currentState = EnemyState.Chase;
        }
    }

    protected override void OnTriggerEnter2D(Collider2D collision)
    {
        base.OnTriggerEnter2D(collision);

        if (collision.CompareTag("Bullet"))
        {
            if (currentHealth > 0)
            {
                currentState = EnemyState.Chase;
            }
        }
    }

    protected override void SubscribeEvent()
    {
    }

    protected override void UnsubscribeEvent()
    {
    }
}
