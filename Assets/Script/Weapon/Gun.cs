using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.U2D;

public class Gun : MonoBehaviour
{
    //Character
    public int currentAmmo;


    //Data
    [HideInInspector] public GunData currentGunData;
    private PlayerStateManager.WeaponInformation currentWeaponInformation;

    //Check Varible
    public bool isReloding;
    private bool isCoolDown;

    //Component
    Transform muzzle;

    private void Awake()
    {
        muzzle = transform.Find("Muzzle").GetComponent<Transform>();

    }

    private void Start()
    {
    }

    public void Shoot(Vector2 dirction)
    {
        if (isCoolDown) return;
        if (isReloding) return;

        if (currentAmmo <= 0)
        {
            Reload();
            return;
        }

        isCoolDown = true;
        currentAmmo--;
        currentWeaponInformation.currentAmmo =currentAmmo;

        //Generate and setting bullet
        float angel = Random.Range(-currentGunData.spreadAngle, currentGunData.spreadAngle);
        dirction = Quaternion.Euler(0f, 0f, angel) * dirction;
        GameObject bulletGameObject = PoolManager.instance.Get("Bullet");
        Bullet bullet = bulletGameObject.GetComponent<Bullet>();
        bulletGameObject.transform.position = muzzle.position;
        bullet.Init(dirction, currentGunData.bulletSpeed, currentGunData.damage);
        StartCoroutine(FireCooldown());
    }

    public void Reload()
    {
        if (isReloding) return;
        if (currentAmmo >= currentGunData.magazineSize) return;

        int reserveAmmo =PlayerStateManager.instance.GetAmmoAmount(currentGunData.ammoType);

        if (reserveAmmo <= 0) return;

        isReloding = true;
        StartCoroutine(ReloadTime());

    }
    public void Equip(PlayerStateManager.WeaponInformation weaponInformation)
    {
        StopAllCoroutines();
        isCoolDown = false;
        isReloding = false;
        currentWeaponInformation = weaponInformation;
        currentGunData =currentWeaponInformation.gunData;
        currentAmmo =currentWeaponInformation.currentAmmo;
        muzzle.localPosition =currentGunData.muzzleLocalPosition;
    }




    //IE
    private IEnumerator FireCooldown()
    {
        yield return new WaitForSeconds(currentGunData.fireInterval);
        isCoolDown = false;
    }

    private IEnumerator ReloadTime()
    {
        yield return new WaitForSeconds(currentGunData.reloadTime);
        int requiredAmmo = currentGunData.magazineSize - currentAmmo;
        int loadedAmmo = PlayerStateManager.instance.TakeAmmoAmount(currentGunData.ammoType, requiredAmmo);
        currentAmmo += loadedAmmo;
        currentWeaponInformation.currentAmmo =currentAmmo;
        isReloding = false;
    }

}
