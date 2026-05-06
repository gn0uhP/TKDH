Shader "Unlit/TerranGrass"
{
    Properties {
        _HeightMap ("Height Map", 2D) = "white" {}
        _HeightScale ("Height Scale", Float) = 1.0
        _TextureTiling ("Texture Tiling", Float) = 10.0
        
        [Header(Grass Settings)]
        _GrassHeight ("Grass Height", Float) = 0.5
        _GrassWidth ("Grass Width", Float) = 0.05
        _WindSpeed ("Wind Speed", Float) = 2.0
        
        _GrassTex ("Grass Texture", 2D) = "white" {}
        _RockTex ("Rock Texture", 2D) = "white" {}
        _SnowTex ("Snow Texture", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom // Khai báo sử dụng Geometry Shader
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2g {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float h : PSIZE; // Lưu cao độ để chuyển cho Geometry
            };

            struct g2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 localPos : TEXCOORD1;
                fixed4 color : COLOR; // Màu riêng cho cỏ
            };

            sampler2D _HeightMap, _GrassTex, _RockTex, _SnowTex;
            float _HeightScale, _TextureTiling, _GrassHeight, _GrassWidth, _WindSpeed;

            // 1. VERTEX SHADER: Đẩy đỉnh tạo đảo
            v2g vert (appdata v) {
                v2g o;
                float h = tex2Dlod(_HeightMap, float4(v.uv, 0, 0)).r;
                
                // Tạo hồ ở giữa
                float dist = distance(v.uv, float2(0.5, 0.5));
                float lakeMask = smoothstep(0.0, 0.25, dist);

                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                worldPos.y += h * _HeightScale * lakeMask;

                o.pos = worldPos; // Lưu vị trí thế giới tạm thời
                o.uv = v.uv;
                o.worldPos = worldPos.xyz;
                o.h = h * lakeMask;
                return o;
            }

            // 2. GEOMETRY SHADER: Sinh ra lá cỏ
            [maxvertexcount(4)] // Mỗi đỉnh mặt đất sinh ra tối đa 1 lá cỏ (3-4 đỉnh mới)
            void geom(point v2g IN[1], inout TriangleStream<g2f> triStream) {
                float h = IN[0].h;
                
                // Chỉ mọc cỏ ở vùng cao độ từ 0.1 đến 0.4 (Vùng đất xanh)
                if (h > 0.1 && h < 0.4) {
                    g2f o;
                    float3 basePos = IN[0].worldPos;
                    
                    // Hiệu ứng gió
                    float wind = sin(_Time.y * _WindSpeed + basePos.x) * 0.1;

                    // Tạo 3 đỉnh cho 1 lá cỏ hình tam giác
                    // Đỉnh 1: Dưới trái
                    o.pos = mul(UNITY_MATRIX_VP, float4(basePos + float3(-_GrassWidth, 0, 0), 1));
                    o.uv = IN[0].uv;
                    o.localPos = basePos;
                    o.color = fixed4(0.1, 0.5, 0.1, 1); // Màu gốc cỏ tối
                    triStream.Append(o);

                    // Đỉnh 2: Dưới phải
                    o.pos = mul(UNITY_MATRIX_VP, float4(basePos + float3(_GrassWidth, 0, 0), 1));
                    o.color = fixed4(0.1, 0.5, 0.1, 1);
                    triStream.Append(o);

                    // Đỉnh 3: Ngọn cỏ (Bị gió thổi)
                    o.pos = mul(UNITY_MATRIX_VP, float4(basePos + float3(wind, _GrassHeight, 0), 1));
                    o.color = fixed4(0.4, 0.8, 0.2, 1); // Ngọn cỏ sáng hơn
                    triStream.Append(o);

                    triStream.RestartStrip();
                }

                // Vẫn phải vẽ mặt đất bên dưới
                g2f ground;
                ground.pos = mul(UNITY_MATRIX_VP, float4(IN[0].worldPos, 1));
                ground.uv = IN[0].uv;
                ground.localPos = IN[0].worldPos;
                ground.color = fixed4(0,0,0,0); // Đánh dấu là mặt đất
                triStream.Append(ground);
            }

            // 3. FRAGMENT SHADER: Tô màu
            fixed4 frag (g2f i) : SV_Target {
                // Nếu là cỏ (có màu từ Geometry Shader)
                if(i.color.a > 0) return i.color;

                // Nếu là mặt đất (như cũ)
                float h = i.localPos.y / _HeightScale;
                float2 uvTiled = i.uv * _TextureTiling;

                fixed4 g = tex2D(_GrassTex, uvTiled);
                fixed4 r = tex2D(_RockTex, uvTiled);
                fixed4 s = tex2D(_SnowTex, uvTiled);

                float t1 = smoothstep(0.15, 0.35, h);
                float t2 = smoothstep(0.60, 0.80, h);

                fixed4 col = lerp(lerp(g, r, t1), s, t2);

                // Màu nước hồ
                if(i.localPos.y < 0.05) {
                    col = lerp(fixed4(0.1, 0.3, 0.6, 1), col, smoothstep(0.0, 0.05, i.localPos.y));
                }
                return col;
            }
            ENDCG
        }
    }
}
