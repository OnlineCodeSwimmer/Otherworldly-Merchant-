using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerStateManager : MonoBehaviour
{
    public static PlayerStateManager instance;


    //Class Data
    [System.Serializable]
    public class AmmoInformation
    {
        public AmmoType ammoType;
        public int amount;  //Ammunition carried by the player
    }

    [System.Serializable]
    public class WeaponInformation
    {
        public GunData gunData;
        public int currentAmmo; //Ammunition in gun magazine
    }

    //State
    [Header("Player States")]
    public float balance;
    public float debt;
    public float health;

    //Weapon
    [Header("WeaponInformation")]
    public List<WeaponInformation> ownGun = new List<WeaponInformation>();
    public int weaponIndex; //To record the weapons currently held by the player
    public List<AmmoInformation> ammoInformation = new List<AmmoInformation>();
    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else if (instance != this)
        {
            Destroy(gameObject);
        }
    }




    public int GetAmmoAmount(AmmoType ammoType)
    {
        foreach (AmmoInformation ammo in ammoInformation)
        {
            if (ammo.ammoType == ammoType)
            {
                return ammo.amount;
            }
        }

        return 0;
    }

    public int TakeAmmoAmount(AmmoType ammoType, int requireAmount)
    {
        foreach (AmmoInformation ammo in ammoInformation)
        {
            if (ammo.ammoType != ammoType) continue;

            int takeAmmoAmount = Mathf.Min(requireAmount, ammo.amount);
            ammo.amount -= takeAmmoAmount;
            return takeAmmoAmount;
        }

        return 0;
    }

    public void AddAmount(AmmoType ammoType, int amount)
    {
        foreach (AmmoInformation ammo in ammoInformation)
        {
            if (ammo.ammoType != ammoType) continue;

            ammo.amount += amount;
            return;
        }
    }

    public void ReloadAllWeaponsOnSceneEnter()
    {
        foreach (WeaponInformation weapon in ownGun)
        {
            int requiredAmmo = weapon.gunData.magazineSize - weapon.currentAmmo;

            if (requiredAmmo <= 0) continue;

            int loadedAmmo = TakeAmmoAmount(weapon.gunData.ammoType,requiredAmmo);
            weapon.currentAmmo += loadedAmmo;
        }

    }

    public bool OwnsGun(GunData gunData)
    {
        for (int i = 0; i < ownGun.Count; i++)
        {
            if (ownGun[i].gunData == gunData) return true;
        }

        return false;
    }

    public void ObtainGun(GunData gunData)
    {
        if (OwnsGun(gunData)) return;

        WeaponInformation weaponInformation = new WeaponInformation();
        weaponInformation.gunData = gunData;
        weaponInformation.currentAmmo = 0;

        ownGun.Add(weaponInformation);
    }
}

