using UnityEngine;

public class RTMyPlane : RTSceneObject
{
    public Vector3 normal = new Vector3(0, 1, 0); // Pháp tuyến (Hướng lên)

    private void OnDrawGizmos()
    {
        Gizmos.color = color;
        // Vẽ một đường thẳng để biết mặt phẳng đang hướng về đâu
        Gizmos.DrawLine(transform.position, transform.position + normal * 2f);
    }
}