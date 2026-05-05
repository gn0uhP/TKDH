using UnityEngine;

public class Wind : MonoBehaviour
{
    public float speed = 1f;
    public float amp = 3f;
    private Quaternion g;

    void Start()
    {
        g = transform.rotation;
    }

    void Update()
    {
        float a = Mathf.Sin(Time.time * speed) * amp;
        transform.rotation = g * Quaternion.Euler(a, 0, a);
    }
}