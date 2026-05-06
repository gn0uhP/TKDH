using UnityEngine;

public class Wind : MonoBehaviour
{
    public float speed = 2f;
    public float amp = 3f;
    private float offset;

    void Start()
    {
        offset = Random.Range(0f, 10f);
    }

    void Update()
    {
        float angle = Mathf.Sin((Time.time + offset) * speed) * amp;
        transform.localRotation = Quaternion.Euler(angle, 0, 0);
    }
}