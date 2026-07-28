
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody2D),typeof(Animator),typeof(PolygonCollider2D))]
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
    private float health;


    //Patrol Varible
    [Header("Patrol Parameter")]
    public float patrolRadius ;
    private Vector2 patrolCenter;
    private Vector2 patrolTarget;
    private bool isPatrolWatiing;

    //Chase Vairible
    [Header("Chase Parameter")]
    public float loseDistance;
    public float detectionDistance ;
    public float attackDistance;


    //Component
    private Rigidbody2D rb;
    private Animator animator;

    private void Awake()
    {
        rb=GetComponent<Rigidbody2D>();
        animator = GetComponent<Animator>();
    }

    private void Start()
    {

    }

    private void OnEnable()
    {
        currentState = EnemyState.Patrol;
        patrolCenter = transform.position;
        SelectNewPatrolPosition();
    }

    private void OnDisable()
    {
        rb.velocity = Vector2.zero;

    }


    private void Update()
    {
        UpdateState();
        AnimationUpdate();
    }

    private void FixedUpdate()
    {
        Move();
    }




    private void UpdateState()
    {
        float distanceSqrMagnitude = ((Vector2)(GameManager.instance.playerController.transform.position - transform.position)).sqrMagnitude;


        switch (currentState)
        {
            case EnemyState.Patrol:

                if (distanceSqrMagnitude < detectionDistance * detectionDistance)
                {
                    currentState = EnemyState.Chase;
                }

                break;

            case EnemyState.Chase:

                if(distanceSqrMagnitude > loseDistance * loseDistance)
                {
                    currentState=EnemyState.Patrol;
                    patrolCenter = transform.position;
                    SelectNewPatrolPosition();

                }
                break;
        }
    }


    private void AnimationUpdate()
    {
        animator.SetFloat("VelocityX", Mathf.Abs(rb.velocity.x));
        animator.SetFloat("VelocityY", Mathf.Abs(rb.velocity.y));
    }

    private void Move()
    {
        Vector2 direction;
        switch (currentState)
        {
           
            case EnemyState.Patrol:
                if (isPatrolWatiing) return;

                 direction = patrolTarget - (Vector2)transform.position;
                transform.right = direction;

                if (direction.sqrMagnitude <= 0.1f)
                {
                    rb.velocity = Vector2.zero;
                    StartCoroutine(PatrolWait());
                    return;
                }
                rb.velocity = patrolSpeed * direction.normalized;

                break;



            case EnemyState.Chase:
                PlayerController player = GameManager.instance.playerController;
                direction = player.transform.position - transform.position;
                transform.right = direction;

                bool isAttack = direction.sqrMagnitude <= attackDistance * attackDistance;
                animator.SetBool("Attack", isAttack);

                if (isAttack)
                {
                    rb.velocity= Vector2.zero;
                    return;
                }

                rb.velocity = chaseSpeed * direction.normalized;

                break;

                
        }
    }
    
    private void SelectNewPatrolPosition()
    {
        Vector2 randomOffset = Random.insideUnitCircle * patrolRadius;
        patrolTarget= patrolCenter + randomOffset;
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
        Gizmos.DrawWireSphere(transform.position, detectionDistance);

        //Lose Chase Area
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, loseDistance);

        //Attack Area
        Gizmos.color= Color.green;
        Gizmos.DrawWireSphere(transform.position, attackDistance);
    }

    private IEnumerator PatrolWait()
    {
        isPatrolWatiing = true;

        yield return new WaitForSeconds(1f);

        SelectNewPatrolPosition();
        isPatrolWatiing = false;
    }
}
