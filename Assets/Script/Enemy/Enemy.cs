using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Pathfinding;

[RequireComponent(typeof(Rigidbody2D),typeof(Animator),typeof(PolygonCollider2D))]
[RequireComponent(typeof(Seeker), typeof(AIPath))]
public class Enemy : MonoBehaviour
{
    //State
    private enum EnemyState
    {
        Patrol,
        Chase
    }

    private EnemyState currentState;

    //Character
    [Header("Character")]
    public float patrolSpeed;
    public float chaseSpeed;
    public float damage;
    public float health;


    //Patrol Varible
    [Header("Patrol Parameter")]
    public float patrolRadius ;
    private Vector2 patrolCenter;
    private Vector2 patrolTarget;
    private bool isPatrolWatiing;

    //Chase Vairible
    [Header("Chase Parameter")]
    public float hearingDistance;
    public float visionDistance ;
    public float attackDistance;
    private LayerMask wallLayer;
    private LayerMask doorLayer;

    //Check Vairible
    private bool isDead;

    //Component
    private Rigidbody2D rb;
    private Animator animator;
    private Bleeding bleeding;
    private AIPath aiPath;
    private PolygonCollider2D polygonCollider2D;

    private void Awake()
    {
        rb=GetComponent<Rigidbody2D>();
        animator = GetComponent<Animator>();
        bleeding = GetComponent<Bleeding>();
        aiPath = GetComponent<AIPath>();
        polygonCollider2D=GetComponent<PolygonCollider2D>();
        wallLayer = LayerMask.GetMask("Wall");
        doorLayer = LayerMask.GetMask("Door");
    }


    private void OnEnable()
    {
        currentState = EnemyState.Patrol;
        patrolCenter = transform.position;
        polygonCollider2D.enabled = true;
        SelectNewPatrolPosition();
    }

    private void OnDisable()
    {
        rb.velocity = Vector2.zero;

    }


    private void Update()
    {
        if (!isDead)
        {
            UpdateState();
            Move();
            MoveAnimationUpdate();

        }
    }





    private void UpdateState()
    {
        Vector2 playerPosition = GameManager.instance.playerController.transform.position;
        Vector2 playerDirection =playerPosition - (Vector2)transform.position;
        float distanceSqrMagnitude = playerDirection.sqrMagnitude;
        bool playerInVisionDistance =distanceSqrMagnitude < visionDistance * visionDistance;
        bool canSeePlayer =playerInVisionDistance && CanSeePlayer(playerPosition);

        switch (currentState)
        {
            case EnemyState.Patrol:

                if (canSeePlayer)
                {
                    currentState = EnemyState.Chase;
                }


                break;

            case EnemyState.Chase:

                if(distanceSqrMagnitude > hearingDistance * hearingDistance)
                {
                    currentState=EnemyState.Patrol;
                    patrolCenter = transform.position;
                    SelectNewPatrolPosition();

                }
                break;
        }
    }


    private void MoveAnimationUpdate()
    {
        Vector2 velocity = aiPath.canMove ? (Vector2) aiPath.velocity :Vector2.zero;

        animator.SetFloat("VelocityX", Mathf.Abs(velocity.x));
        animator.SetFloat("VelocityY", Mathf.Abs(velocity.y));
    }
    private bool CanSeePlayer(Vector2 playerPosition)
    {

        RaycastHit2D wallHit = Physics2D.Linecast(transform.position,playerPosition,wallLayer);
        RaycastHit2D doorHit= Physics2D.Linecast(transform.position,playerPosition,doorLayer);
        return wallHit.collider == null && doorHit.collider == null;
    }

    private void Move()
    {

        switch (currentState)
        {
            case EnemyState.Patrol:
                if (isPatrolWatiing) return;


                aiPath.canMove = true;
                aiPath.maxSpeed = patrolSpeed;
                aiPath.destination = patrolTarget;

                if (aiPath.reachedDestination)
                {
                    StartCoroutine(PatrolWait());
                }

                break;


            case EnemyState.Chase:

                PlayerController player =GameManager.instance.playerController;
                Vector2 playerDirection =player.transform.position - transform.position;
                bool isAttack = playerDirection.sqrMagnitude <= attackDistance * attackDistance;
                animator.SetBool("Attack", isAttack);

                aiPath.destination =player.transform.position;
                aiPath.maxSpeed = chaseSpeed;

                if (isAttack)
                {
                    aiPath.canMove = false;
                    rb.velocity = Vector2.zero;
                    transform.right = playerDirection;
                }
                else
                {
                    aiPath.canMove = true;
                }

                break;
        }

        Vector2 moveDirection = aiPath.steeringTarget - transform.position;

        if (aiPath.canMove && moveDirection.sqrMagnitude > 0.01f)
        {
            transform.right = moveDirection;
        }
    }
    
    private void SelectNewPatrolPosition()
    {
        Vector2 randomOffset = Random.insideUnitCircle * patrolRadius;
        Vector2 randomPosition = patrolCenter + randomOffset;
        NNInfo nearestNode = AstarPath.active.GetNearest(randomPosition);
        patrolTarget = nearestNode.position;

    }

    private void OnDrawGizmos()
    {
        //patrol Area
        Vector2 drawPatrolCenter = Application.isPlaying ? patrolCenter : transform.position;
        Gizmos.color = Color.white;
        Gizmos.DrawWireSphere(drawPatrolCenter, patrolRadius);

        //Point of patrol
        if(Application.isPlaying && currentState== EnemyState.Patrol)
        {
            Gizmos.color = Color.blue;
            Gizmos.DrawWireSphere(patrolTarget, 0.05f);
        }

        //Discovery Area
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, visionDistance);

        //Lose Chase Area
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, hearingDistance);

        //Attack Area
        Gizmos.color= Color.green;
        Gizmos.DrawWireSphere(transform.position, attackDistance);
    }




    private IEnumerator PatrolWait()
    {
        isPatrolWatiing = true;
        aiPath.canMove = false;

        yield return new WaitForSeconds(1f);

        SelectNewPatrolPosition();
        aiPath.destination = patrolTarget;
        isPatrolWatiing = false;

    }


    private void Die()
    {
        isDead = true;
        aiPath.canMove = false;
        rb.velocity = Vector2.zero;
        polygonCollider2D.enabled = false;
        health = 0;
        animator.SetBool("Attack", false);
        animator.SetBool("Dead", isDead);
    }


    //Trrigger Area
    private void OnTriggerEnter2D(Collider2D collision)
    {
       if( collision.CompareTag("Bullet"))
        {
            Bullet bullet = collision.GetComponent<Bullet>();

            if (health > 0)
            {
                health -= bullet.currentDamage;
                bleeding.BloodSpawn(bullet.moveDirection);
            }
            else
            {
                Die();
            }

        }

    }


}
