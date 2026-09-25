using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemySpawnManager : MonoBehaviour
{
    //Spawn Class Data
    [System.Serializable]
    public class SpawnAreaData
    {
        public string areaName;
        public Transform[] spawnPoints;
        public int minEnemyCount = 1;
        public int maxEnemyCount = 3;
        public GameObject[] enemyPrefabs;
    }

    //Spawn Point Setting
    [Header("Spawn Point Setting")]
    public SpawnAreaData[] spawnAreas;





    public void SpawnEnemies()
    {
        for (int i = 0; i < spawnAreas.Length; i++)
        {
            SpawnArea(spawnAreas[i]);
        }
    }

    private void SpawnArea(SpawnAreaData area)
    {
        int spawnCount = Random.Range(area.minEnemyCount, area.maxEnemyCount + 1);
        Transform[] points = (Transform[])area.spawnPoints.Clone();

        for (int i = 0; i < spawnCount; i++)
        {
            // 洗牌：从尚未使用的刷新点中随机选择一个
            int randomIndex = Random.Range(i, points.Length);

            Transform temp = points[i];
            points[i] = points[randomIndex];
            points[randomIndex] = temp;

            // 随机选择这个区域允许出现的怪物
            int enemyIndex = Random.Range(0, area.enemyPrefabs.Length);
            GameObject enemy = PoolManager.instance.Get(area.enemyPrefabs[enemyIndex].name);

            enemy.transform.position = points[i].position;
            enemy.GetComponent<Enemy>().ResetPatrolPosition();
        }
    }

}
