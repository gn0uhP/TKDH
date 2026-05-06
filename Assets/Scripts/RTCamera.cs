using UnityEngine;

public class RTCamera : MonoBehaviour
{
    public ComputeShader rayTracingShader; //[cite: 11]
    public RTSceneObject[] objects; //[cite: 11]

    private RenderTexture target; //[cite: 11]
    private ComputeBuffer objectBuffer; //[cite: 11]

    // Thêm nút tự động tìm vật thể cho tiện
    [ContextMenu("Tự động quét tất cả vật thể")]
    public void AutoFindAllObjects()
    {
        objects = FindObjectsByType<RTSceneObject>(FindObjectsInactive.Exclude, FindObjectsSortMode.None);

        Debug.Log("Đã tự động tìm thấy " + objects.Length + " vật thể!");
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination) //[cite: 11]
    {
        SetShaderParameters(); //[cite: 11]
        Render(destination); //[cite: 11]
    }

    private void SetShaderParameters() //[cite: 11]
    {
        // 1. Tạo mảng Struct để gói dữ liệu từ các GameObjects[cite: 11]
        ObjectData[] objectDatas = new ObjectData[objects.Length]; //[cite: 11]

        for (int i = 0; i < objects.Length; i++) //[cite: 11]
        {
            if (objects[i] is RTMySphere sphere) //[cite: 11]
            {
                objectDatas[i] = new ObjectData() //[cite: 11]
                {
                    type = 0, //[cite: 11]
                    center = sphere.transform.position, //[cite: 11]
                    radius = sphere.radius, //[cite: 11]
                    color = new Vector3(sphere.color.r, sphere.color.g, sphere.color.b), //[cite: 11]
                    isMirror = sphere.isMirror ? 1 : 0 //[cite: 11]
                };
            }
            else if (objects[i] is RTMyPlane plane) //[cite: 11]
            {
                objectDatas[i] = new ObjectData() //[cite: 11]
                {
                    type = 1, //[cite: 11]
                    center = plane.transform.position, //[cite: 11]
                    normal = plane.normal.normalized, //[cite: 11]
                    color = new Vector3(plane.color.r, plane.color.g, plane.color.b), //[cite: 11]
                    isMirror = plane.isMirror ? 1 : 0 //[cite: 11]
                };
            }
            // BỔ SUNG: Xử lý Gương chiếu hậu ô tô
            else if (objects[i] is RTMyQuad quad)
            {
                objectDatas[i] = new ObjectData()
                {
                    type = 2, // Đánh dấu là 2
                    center = quad.transform.position,
                    normal = quad.transform.forward.normalized, // Mặt gương quay về phía trước
                    color = new Vector3(quad.color.r, quad.color.g, quad.color.b),
                    isMirror = quad.isMirror ? 1 : 0,
                    size = quad.size // Gửi kích thước sang GPU
                };
            }
        }

        // 2. Gửi gói hàng (ComputeBuffer) sang VRAM của GPU[cite: 11]
        // Kích thước struct mới: 4 + 12 + 4 + 12 + 12 + 4 + 8 (Vector2) = 56 bytes
        if (objectBuffer != null) objectBuffer.Release(); //[cite: 11]

        // Tránh lỗi GPU báo mảng rỗng nếu Scene chưa có vật thể nào
        if (objectDatas.Length > 0)
        {
            objectBuffer = new ComputeBuffer(objectDatas.Length, 56);
            objectBuffer.SetData(objectDatas); //[cite: 11]
            rayTracingShader.SetBuffer(0, "SceneObjects", objectBuffer); //[cite: 11]
        }

        rayTracingShader.SetInt("ObjectCount", objects.Length); //[cite: 11]

        // Gửi luôn vị trí và góc nhìn của Camera hiện tại sang GPU[cite: 11]
        rayTracingShader.SetMatrix("_CameraToWorld", transform.localToWorldMatrix); //[cite: 11]
        rayTracingShader.SetMatrix("_CameraInverseProjection", GetComponent<Camera>().projectionMatrix.inverse); //[cite: 11]
    }

    private void Render(RenderTexture destination) //[cite: 11]
    {
        if (target == null || target.width != Screen.width || target.height != Screen.height) //[cite: 11]
        {
            if (target != null) target.Release(); //[cite: 11]
            target = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear); //[cite: 11]
            target.enableRandomWrite = true; //[cite: 11]
            target.Create(); //[cite: 11]
        }

        rayTracingShader.SetTexture(0, "Result", target); //[cite: 11]
        int threadGroupsX = Mathf.CeilToInt(Screen.width / 8.0f); //[cite: 11]
        int threadGroupsY = Mathf.CeilToInt(Screen.height / 8.0f); //[cite: 11]
        rayTracingShader.Dispatch(0, threadGroupsX, threadGroupsY, 1); //[cite: 11]

        Graphics.Blit(target, destination); //[cite: 11]
    }

    private void OnDisable() //[cite: 11]
    {
        if (objectBuffer != null) objectBuffer.Release(); //[cite: 11]
    }

    public struct ObjectData //[cite: 11]
    {
        public int type; //[cite: 11]
        public Vector3 center; //[cite: 11]
        public float radius;  //[cite: 11]
        public Vector3 normal;   //[cite: 11]
        public Vector3 color;  //[cite: 11]
        public int isMirror;   //[cite: 11]
        public Vector2 size; // Thêm chiều Rộng/Cao cho cái Quad
    }
}