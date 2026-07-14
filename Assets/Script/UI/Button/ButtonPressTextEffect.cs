using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ButtonPressTextEffect : MonoBehaviour
{
    private Text uiText;

    //Position Varible
    private Vector2 pressedOffset = new Vector2(2f, -2f);
    private Vector2 originalPosition;


    private void Awake()
    {
        uiText = GetComponentInChildren<Text>();
    }
    private void Start()
    {
        originalPosition = uiText.rectTransform.anchoredPosition;
    }
    public void Press()
    {
        uiText.rectTransform.anchoredPosition = originalPosition + pressedOffset;
    }

    public void Release()
    {
        uiText.rectTransform.anchoredPosition = originalPosition;
    }
}
