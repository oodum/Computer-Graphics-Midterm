using System;
using UnityEngine;
using UnityEngine.InputSystem;
using Random = System.Random;

public class PlayerController : MonoBehaviour {
    [SerializeField] Pill[] pills;
    Pill currentPill;
    [SerializeField] Transform spawnPosition;

    void Start() {
        SpawnPill();
    }

    void SpawnPill() {
        currentPill = Instantiate(pills[new Random().Next(0, pills.Length)], spawnPosition.position, Quaternion.identity);
    }
    void Update() {
        if (Keyboard.current.leftArrowKey.wasPressedThisFrame) {
            currentPill.transform.Translate(Vector3.left * (3 * Time.deltaTime));
        }
        if (Keyboard.current.rightArrowKey.wasPressedThisFrame) {
            currentPill.transform.Translate(Vector3.right * (3 * Time.deltaTime));
        }
        if (currentPill.Touching) SpawnPill();
    }
}