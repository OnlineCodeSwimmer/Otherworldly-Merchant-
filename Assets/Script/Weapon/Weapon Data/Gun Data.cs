using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu (fileName = "New Weapon Data",menuName ="Data/GunData")]
public class GunData : ScriptableObject
{
    //Basic Imformation
    [Header("Basic Imformation")]
    public float damage;
    public float fireInterval;
    public float fireDistance;
    public float bulletSpeed;
    public float spreadAngle;
    public int magazineSize;
    public float reloadTime;
    public FireMode fireMode;
    public AmmoType ammoType;

    //Apprence Imformation
    [Header("Weapon Appearance")]
    public AnimatorOverrideController animatorOverrideController;
    public Vector2 muzzleLocalPosition;
    public Sprite gunIcon;
    public Vector2 iconSize;
}
