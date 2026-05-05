Shader "Unlit/TerranHeight"
{
    Properties {
        _HeightMap ("Height Map", 2D) = "white" {}
        _HeightScale ("Height Scale", Float) = 1.0
        
        // THÊM: Biến chỉnh độ lặp của Texture (Số càng to, texture càng bé)
        _TextureTiling ("Texture Tiling", Float) = 50.0 
        
        _GrassTex ("Grass Texture", 2D) = "white" {}
        _RockTex ("Rock Texture", 2D) = "white" {}
        _SnowTex ("Snow Texture", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 localPos : TEXCOORD1;
            };

            sampler2D _HeightMap;
            sampler2D _GrassTex;
            sampler2D _RockTex;
            sampler2D _SnowTex;
            float _HeightScale;
            
            // THÊM: Khai báo biến Tiling để code bên dưới có thể sử dụng
            float _TextureTiling; 

            v2f vert (appdata v) {
                v2f o;
                float h = tex2Dlod(_HeightMap, float4(v.uv, 0, 0)).r;
                v.vertex.y += h * _HeightScale;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.localPos = v.vertex.xyz; // Lưu lại để tính màu ở frag shader
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float h = i.localPos.y / _HeightScale; // Chuẩn hóa về dải 0-1
                
                // THÊM: Tạo một UV mới đã được nhân với Tiling
                float2 uvTiled = i.uv * _TextureTiling; 
                
                // SỬA: Thay i.uv bằng uvTiled cho các texture màu
                fixed4 g = tex2D(_GrassTex, uvTiled);
                fixed4 r = tex2D(_RockTex, uvTiled);
                fixed4 s = tex2D(_SnowTex, uvTiled);

                float t1 = smoothstep(0.25, 0.35, h);
                float t2 = smoothstep(0.65, 0.75, h);

                fixed4 col = lerp(g, r, t1);
                col = lerp(col, s, t2);
                
                return col;
            }
            ENDCG
        }
    }
}