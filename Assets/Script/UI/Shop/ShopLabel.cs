using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ShopLabel : MonoBehaviour
{

    //Component
    private Button button;

    //Check Varible
    [Header("Is Default Press?")]
    public bool isPressedDefault = false;

    //Page
    [Header("Page")]
    public GameObject[] otherPages;
    public GameObject targetPage;
    private void Awake()
    {
        button = GetComponent<Button>();
    }

    private void OnEnable()
    {
        if (isPressedDefault)
        {
            button.Select();
            OnPointerClick();
        }

    }
    private void Start()
    {
    }
    public void OnPointerClick()
    {
        foreach (GameObject otherPage in otherPages)
        {
            otherPage.SetActive(false);
        }

        targetPage.SetActive(true);
    }


}
