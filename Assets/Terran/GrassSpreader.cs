using UnityEngine;

public class GrassSpreader : MonoBehaviour {
    public GameObject grassPrefab; // Kéo Model cỏ vào đây
    public Texture2D heightMap;    // Kéo ảnh trắng đen vào đây
    public float heightScale = 5f; // Phải trùng với _HeightScale trong Shader
    public int grassCount = 1000;  // Số lượng bụi cỏ

    void Start() {
        for (int i = 0; i < grassCount; i++) {
            // Lấy vị trí ngẫu nhiên trên Plane (0 đến 1)
            float x = Random.value;
            float z = Random.value;

            // Đọc độ cao từ ảnh HeightMap
            float h = heightMap.GetPixelBilinear(x, z).r;

            // Chỉ mọc cỏ ở vùng độ cao cho phép (ví dụ từ 0.2 đến 0.4)
            if (h > 0.2f && h < 0.4f) {
                Vector3 pos = new Vector3(x * 10, h * heightScale, z * 10); // Nhân với size của Plane
                Instantiate(grassPrefab, pos, Quaternion.identity, transform);
            }
        }
    }
}
