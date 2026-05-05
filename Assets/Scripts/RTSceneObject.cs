using UnityEngine;

// Lớp cha cho tất cả vật thể Ray Tracing
public abstract class RTSceneObject : MonoBehaviour
{
    public Color color = Color.white;
    public bool isMirror = false; // Giữ lại biến này phòng khi sau này bạn muốn làm gương lại

    // ĐÃ XÓA hàm virtual HitData Intersect(...) vì C# không cần tính toán nữa!
}