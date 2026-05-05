using UnityEngine;

public class RTMySphere : RTSceneObject
{
    public float radius = 1.0f; // Bán kính

    private void OnDrawGizmos()
    {
        Gizmos.color = color;
        Gizmos.DrawWireSphere(transform.position, radius);
    }
}