using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HeartUI : MonoBehaviour
{
    public Sprite[] heartSprites;

    //Component
    private Image heartImage;


    private void Awake()
    {
        heartImage = GetComponent<Image>();
    }
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        UpdateHeart();
    }

    private void UpdateHeart()
    {
        float health = PlayerStateManager.instance.health;
        float maxHealth =GameManager.instance.playerController.maxHealth;
        float healthPercent =health / maxHealth;

        if (healthPercent <= 0f)
        {
            heartImage.sprite = heartSprites[0];
        }
        else if (healthPercent <= 0.25f)
        {
            heartImage.sprite = heartSprites[1];
        }
        else if (healthPercent <= 0.5f)
        {
            heartImage.sprite = heartSprites[2];
        }
        else if (healthPercent <= 0.75f)
        {
            heartImage.sprite = heartSprites[3];
        }
        else
        {
            heartImage.sprite = heartSprites[4];
        }
    }
}
