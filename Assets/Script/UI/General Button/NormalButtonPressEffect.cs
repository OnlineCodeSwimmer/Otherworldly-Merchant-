using UnityEngine;
using UnityEngine.UI;
using static UnityEngine.Rendering.DebugUI;

public class NormalButtonPressEffect : MonoBehaviour
{
    //Button Base Component
    public Text uiText;
    public Image uiPanel;

    //Text and panel orginal color
    private Color originalTextColor;
    private Color originalPanelColor;

    //Text and panel change color when mouse enter
    [Header("Text and Panel Change Color")]
    public Color textChangeColor;
    public Color panelChangeColor;

    //Position Varible
    private Vector2 pressedOffset = new Vector2(2f, -2f);
    private Vector2 originalPosition;


    private void Awake()
    {
        uiText = GetComponentInChildren<Text>();
    }
    private void Start()
    {
        if (uiText != null)
        {
            originalPosition = uiText.rectTransform.anchoredPosition;
            originalTextColor = uiText.color;
        }

        if (uiPanel != null)
        {
            originalPanelColor = uiPanel.color;
        }
    }


    public void MouseEnterChangeColor()
    {
        uiText.color = textChangeColor;
        uiPanel.color = panelChangeColor;
    }

    public void MouseRealseChangeColor()
    {
        uiText.color = originalTextColor;
        uiPanel.color = originalPanelColor;
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
