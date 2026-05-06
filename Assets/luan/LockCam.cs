using UnityEngine;

public class LockCam : MonoBehaviour
{
    Vector3 v;
    Quaternion g;

    void Start()
    {
        v = transform.position;
        g = transform.rotation;
        transform.SetParent(null);
    }

    void LateUpdate()
    {
        transform.position = v;
        transform.rotation = g;
    }
}