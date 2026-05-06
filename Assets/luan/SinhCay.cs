using UnityEngine;

public class SinhCay : MonoBehaviour
{
    public GameObject m;
    public int sl = 50;
    public float bk = 20f;
    public LayerMask ld;

    void Start()
    {
        T();
    }

    void T()
    {
        for (int i = 0; i < sl; i++)
        {
            Vector2 n = Random.insideUnitCircle * bk;
            Vector3 t = transform.position + new Vector3(n.x, 100f, n.y);
            
            if (Physics.Raycast(t, Vector3.down, out RaycastHit d, 200f, ld))
            {
                Instantiate(m, d.point, Quaternion.identity, transform);
            }
        }
    }
}