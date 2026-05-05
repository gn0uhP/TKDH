using UnityEngine;

public class RTMyQuad : RTSceneObject
{
    public Vector2 size = new Vector2(2f, 2f); // Chiều Rộng và Cao

    private void OnDrawGizmos()
    {
        Gizmos.color = color;
        Gizmos.matrix = transform.localToWorldMatrix;
        // Vẽ một khung hình chữ nhật trong Scene
        Gizmos.DrawWireCube(Vector3.zero, new Vector3(size.x, size.y, 0.01f));
        Gizmos.matrix = Matrix4x4.identity;
    }
}