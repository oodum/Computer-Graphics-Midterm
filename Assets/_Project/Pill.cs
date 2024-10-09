using System;
using UnityEngine;
public class Pill : MonoBehaviour {
    public bool Touching = false;

    void OnCollisionEnter(Collision other) {
        if (other.gameObject.CompareTag("Enemy")) Touching = true;
    }

    void Update() {
        if (!Touching)
            transform.position += Vector3.down * (3 * Time.deltaTime);
    }
}
