using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Tilemaps;

// Editor-only inspection and layout tools for the Clinic scene.
[InitializeOnLoad]
public static class ClinicFloorLayout
{
    private const string WorkDirectory = "tmp/floor-layout";
    private const string ClinicPath = "Assets/Scenes/Clinic.unity";
    private const string LayoutPath = "Assets/Scenes/Clinic Floor 3 Layout.unity";
    private const string RequestPath = WorkDirectory + "/finalize.request";
    private static bool validationOnly;
    private static readonly Vector3Int[] DoorCells = {
        new Vector3Int(9, 7, 0), new Vector3Int(21, 7, 0), new Vector3Int(34, 7, 0),
        new Vector3Int(10, 2, 0), new Vector3Int(26, 2, 0), new Vector3Int(37, 2, 0)
    };

    static ClinicFloorLayout()
    {
        EditorApplication.delayCall += FinalizeRequested;
        EditorSceneManager.sceneOpened += (scene, mode) => {
            if (scene.path == ClinicPath) EditorApplication.delayCall += FinalizeRequested;
        };
    }

    private static void FinalizeRequested()
    {
        Directory.CreateDirectory(WorkDirectory);
        File.WriteAllText(WorkDirectory + "/editor-state.txt", "Playing: " + EditorApplication.isPlaying + "\n" +
            string.Join("\n", Enumerable.Range(0, SceneManager.sceneCount).Select(i => {
                var loaded = SceneManager.GetSceneAt(i);
                return "Scene: " + loaded.path + " | " + loaded.name + " | loaded=" + loaded.isLoaded;
            })) + "\nFloors:\n" + string.Join("\n", Resources.FindObjectsOfTypeAll<Transform>()
                .Where(t => t.name.StartsWith("Floor ")).Select(t => t.name + " | " + t.gameObject.scene.path)));
        if (EditorApplication.isPlayingOrWillChangePlaymode) return;
        if (!File.Exists(RequestPath)) return;
        var scene = SceneManager.GetSceneByPath(ClinicPath);
        bool openedForValidation = !scene.IsValid() || !scene.isLoaded;
        var previousScene = SceneManager.GetActiveScene();
        var previousSelection = Selection.activeObject;
        try
        {
            // Validate the saved Clinic without closing or saving the user's
            // currently open Home scene, including any unsaved edits there.
            validationOnly = openedForValidation;
            if (openedForValidation) scene = EditorSceneManager.OpenScene(ClinicPath, OpenSceneMode.Additive);
            FinalizeFloor();
            File.Delete(RequestPath);
        }
        catch (Exception error)
        {
            Directory.CreateDirectory(WorkDirectory);
            File.WriteAllText(WorkDirectory + "/unity-validation.txt", "FAILED\n" + error);
            Debug.LogException(error);
        }
        finally
        {
            validationOnly = false;
            if (openedForValidation && scene.IsValid() && scene.isLoaded)
            {
                EditorSceneManager.CloseScene(scene, true);
                if (previousScene.IsValid() && previousScene.isLoaded) SceneManager.SetActiveScene(previousScene);
                Selection.activeObject = previousSelection;
            }
        }
    }

    [MenuItem("Tools/Clinic Floor/Finalize and Select Floor 3")]
    public static void FinalizeFloor()
    {
        Directory.CreateDirectory(WorkDirectory);
        if (EditorApplication.isPlayingOrWillChangePlaymode)
            throw new InvalidOperationException("Exit Play Mode before editing the floor.");
        var scene = SceneManager.GetSceneByPath(ClinicPath);
        if (!scene.IsValid() || !scene.isLoaded) throw new InvalidOperationException("Open Clinic first.");
        var source = Find(scene, "Floor 1");
        if (source == null) throw new InvalidOperationException("Floor 1 was not found.");
        var floor = Find(scene, "Floor 3");

        // Import additively when the editor still holds the pre-edit scene.
        // Saving a backup first preserves all in-memory work.
        if (floor == null)
        {
            if (!EditorSceneManager.SaveScene(scene, WorkDirectory + "/Clinic.before-live-import.unity", true))
                throw new IOException("Could not back up the loaded Clinic scene.");
            var fragment = EditorSceneManager.OpenScene(LayoutPath, OpenSceneMode.Additive);
            try
            {
                floor = Find(fragment, "Floor 3");
                if (floor == null) throw new InvalidDataException("Layout asset has no Floor 3.");
                SceneManager.MoveGameObjectToScene(floor.gameObject, scene);
                floor.SetParent(source.parent, true);
                Undo.RegisterCreatedObjectUndo(floor.gameObject, "Add Clinic Floor 3");
            }
            finally { EditorSceneManager.CloseScene(fragment, true); }
        }
        RestoreInventoryReferences(source, floor);
        foreach (var map in floor.GetComponentsInChildren<Tilemap>(true))
        {
            Undo.RecordObject(map, "Refresh Floor 3 tiles");
            map.CompressBounds();
            map.RefreshAllTiles();
        }
        foreach (var collider in floor.GetComponentsInChildren<TilemapCollider2D>(true)) collider.ProcessTilemapChanges();
        foreach (var collider in floor.GetComponentsInChildren<CompositeCollider2D>(true)) collider.GenerateGeometry();
        foreach (var joint in floor.GetComponentsInChildren<HingeJoint2D>(true))
        {
            Undo.RecordObject(joint, "Align Floor 3 door hinge");
            Vector2 anchor = joint.transform.TransformPoint(joint.anchor);
            joint.autoConfigureConnectedAnchor = false;
            joint.connectedAnchor = joint.connectedBody == null ? anchor : (Vector2)joint.connectedBody.transform.InverseTransformPoint(anchor);
            PrefabUtility.RecordPrefabInstancePropertyModifications(joint);
        }
        Physics2D.SyncTransforms();
        var originalGround = source.Find("Grid/Floor").GetComponent<Tilemap>();
        var ground = floor.Find("Grid/Floor").GetComponent<Tilemap>();
        var walls = floor.Find("Grid/Wall").GetComponent<Tilemap>();
        var wallCollider = walls.GetComponent<CompositeCollider2D>();
        int count = CountTiles(ground);
        if (count != CountTiles(originalGround) || ground.cellBounds.size != originalGround.cellBounds.size)
            throw new InvalidDataException("Floor 3's painted area or bounds differ from Floor 1.");
        if (wallCollider.pathCount == 0 || !wallCollider.OverlapPoint(walls.GetCellCenterWorld(new Vector3Int(-10, 0, 0))))
            throw new InvalidDataException("The new wall collision geometry was not generated.");
        foreach (var door in DoorCells)
            for (int x = 0; x < 2; x++)
            {
                var cell = door + new Vector3Int(x, 0, 0);
                if (!ground.HasTile(cell) || walls.HasTile(cell) || walls.GetComponent<CompositeCollider2D>().OverlapPoint(walls.GetCellCenterWorld(cell)))
                    throw new InvalidDataException("Wall collision obstructs doorway " + cell);
            }
        if (floor.GetComponentsInChildren<Transform>(true).Any(t => GameObjectUtility.GetMonoBehavioursWithMissingScriptCount(t.gameObject) > 0))
            throw new InvalidDataException("Floor 3 has a missing script reference.");
        EditorSceneManager.MarkSceneDirty(scene);
        if (!EditorSceneManager.SaveScene(scene)) throw new IOException("Could not save Clinic.");
        if (!validationOnly)
        {
            Selection.activeGameObject = floor.gameObject;
            EditorGUIUtility.PingObject(floor.gameObject);
            if (SceneView.lastActiveSceneView != null)
            {
                SceneView.lastActiveSceneView.in2DMode = true;
                SceneView.lastActiveSceneView.FrameSelected();
            }
        }
        File.WriteAllText(WorkDirectory + "/unity-validation.txt", "PASS\nScene: " + ClinicPath +
            "\nFloor: Floor 3\nPainted cells: " + count + "\nGround bounds: " + ground.cellBounds +
            "\nWall bounds: " + walls.cellBounds + "\nDoorways checked: 6\nHinge anchors aligned: " +
            floor.GetComponentsInChildren<HingeJoint2D>(true).Length + "\nSaved: " + DateTime.Now.ToString("O"));
        Debug.Log("Clinic Floor 3 saved: same painted area, six accessible rooms, collision and hinges refreshed.");
    }

    private static void RestoreInventoryReferences(Transform source, Transform destination)
    {
        var roomNames = new System.Collections.Generic.Dictionary<string, string> {
            { "Hall - Reception and Waiting", "Hall" },
            { "Examination Room 1 - North West", "Examination Room1" },
            { "Examination Room 2 - North Centre", "Examination Room2" },
            { "Treatment Room - North East", "Medical Room" },
            { "Pharmacy - South West", "Pharmacy" },
            { "Mens Restroom - South Centre", "Men's restroom" },
            { "Womens Restroom - South East", "Women's restroom (1)" }
        };
        foreach (var component in destination.GetComponentsInChildren<MonoBehaviour>(true))
        {
            if (component == null) continue;
            var serialized = new SerializedObject(component);
            var property = serialized.FindProperty("inventoryWindow");
            if (property == null || property.objectReferenceValue != null) continue;
            string path = AnimationUtility.CalculateTransformPath(component.transform, destination);
            int slash = path.IndexOf('/');
            if (slash < 0 || !roomNames.TryGetValue(path.Substring(0, slash), out string oldRoom)) continue;
            var oldTransform = source.Find(oldRoom + path.Substring(slash));
            if (oldTransform == null) continue;
            var oldComponent = oldTransform.GetComponent(component.GetType());
            if (oldComponent == null) continue;
            var oldProperty = new SerializedObject(oldComponent).FindProperty("inventoryWindow");
            if (oldProperty == null) continue;
            property.objectReferenceValue = oldProperty.objectReferenceValue;
            serialized.ApplyModifiedProperties();
            PrefabUtility.RecordPrefabInstancePropertyModifications(component);
        }
    }

    private static Transform Find(Scene scene, string name)
    {
        return scene.GetRootGameObjects().SelectMany(go => go.GetComponentsInChildren<Transform>(true)).FirstOrDefault(t => t.name == name);
    }

    private static int CountTiles(Tilemap map)
    {
        int count = 0;
        foreach (var position in map.cellBounds.allPositionsWithin) if (map.HasTile(position)) count++;
        return count;
    }
}
