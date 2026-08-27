using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;
using UnityEngine.UI;


public class ComputerIconButton : MonoBehaviour
{
    private static ComputerIconButton currentSelectedButton;

    //Icon Button && Text
    private Image buttonImage;
    private Text iconText;

    //Color
    public Color selectedButtonColor = new Color32(131, 149, 255, 255);
    private Color originalButtonColor;
    private Color originalTextColor;

    //Check Varible
    private bool isSelected=false;

    //Page
    [Header("Page")]
    public GameObject currentPage;
    public GameObject targetPage;

    //Transform
    RectTransform rectTransform; 

    private void Awake()
    {
        buttonImage = GetComponent<Image>();
        iconText = GetComponentInChildren<Text>();
        rectTransform = GetComponentInChildren<RectTransform>();

        originalButtonColor = buttonImage.color;
        originalTextColor = iconText.color;
        targetPage.SetActive(false);
    }

    private void Update()
    {
        CheckClickOutSideButton();
    }

    public void OnPointerClick()
    {
        if (isSelected == false)
        {
            if (currentSelectedButton != null && currentSelectedButton != this)
            {
                currentSelectedButton.SetSelected(false);
            }
            currentSelectedButton = this;
            SetSelected(true);

            return;
        }

        //Open Page
       currentPage.SetActive(false);
       targetPage.SetActive(true);
       SetSelected(false);
    }

    private void SetSelected(bool selected)
    {
        isSelected = selected;
        buttonImage.color = selected ? selectedButtonColor : originalButtonColor;
        iconText.color = selected ? Color.blue : originalTextColor;

    }


    private void CheckClickOutSideButton()
    {
        if(isSelected == false) return;

        if (Mouse.current.leftButton.wasPressedThisFrame == false) return;

        Vector2 mousePosition = Mouse.current.position.ReadValue();
        bool mouseIsOnThisButton = RectTransformUtility.RectangleContainsScreenPoint(rectTransform,mousePosition);

        if (mouseIsOnThisButton == false)
        {
           if (currentSelectedButton == null) return;

           currentSelectedButton.SetSelected(false);
           currentSelectedButton = null;
        }


    }

}
