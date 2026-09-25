using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[CreateAssetMenu(fileName = "New Enemy Data", menuName = "Data/Enemy Data")]

public class EnemyData : ScriptableObject
{
    [Header("Character")]
    public float maxHealth;
    public float damage;
    public float patrolSpeed;
    public float chaseSpeed;

    [Header("Patrol")]
    public float patrolRadius;

    [Header("Detection Distance")]
    public float hearingDistance;
    public float visionDistance;
    public float attackDistance;



}

