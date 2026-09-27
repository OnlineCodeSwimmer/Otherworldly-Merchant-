using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu( fileName = "New Commute Character", menuName = "Data/Commute/Character")]
public class CommuteCharacterData : ScriptableObject
{
    public string characterName;
    public Sprite avatar;
}
