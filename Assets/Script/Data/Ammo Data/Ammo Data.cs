using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[CreateAssetMenu(fileName = "New Ammo Data", menuName = "Data/AmmoData")]

public class AmmoData : ShoppingProductData
{
    [Header("Base Informaiton")]
    public AmmoType ammoType;
}
