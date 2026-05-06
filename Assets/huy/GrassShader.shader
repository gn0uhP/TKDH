Shader "Custom/Grass_ECHOS_Final" {
    Properties {
        _MainTex ("Grass Texture", 2D) = "white" {}
        _Speed ("Sway Speed", Range(0, 10)) = 2.0
        _Amount ("Sway Amount", Range(0, 1)) = 0.5
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
    }
    SubShader {
        Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" "IgnoreProjector"="True" }
        LOD 100
        Cull Off 

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom 
            #pragma fragment frag
            #pragma multi_compile_instancing // Cực kỳ quan trọng để vẽ trên đảo
            #include "UnityCG.cginc"

            struct v2g {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID 
            };

            struct g2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float _Speed, _Amount, _Cutoff;

            v2g vert (appdata_full v) {
                v2g o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.pos = v.vertex;
                o.uv = v.texcoord;
                return o;
            }

            [maxvertexcount(12)]
            void geom(point v2g IN[1], inout TriangleStream<g2f> triStream) {
                UNITY_SETUP_INSTANCE_ID(IN[0]);
                float3 basePos = IN[0].pos.xyz;
                float sway = sin(_Time.y * _Speed) * _Amount;

                for (int j = 0; j < 3; j++) {
                    float angle = j * 1.047;
                    float cosA = cos(angle), sinA = sin(angle);
                    g2f v[4];
                    // Chân cỏ cố định tại y=0
                    v[0].pos = UnityObjectToClipPos(basePos + float3(-0.5 * cosA, 0, -0.5 * sinA));
                    v[1].pos = UnityObjectToClipPos(basePos + float3(0.5 * cosA, 0, 0.5 * sinA));
                    // Ngọn cỏ đung đưa
                    v[2].pos = UnityObjectToClipPos(basePos + float3(-0.5 * cosA + sway, 1.2, -0.5 * sinA));
                    v[3].pos = UnityObjectToClipPos(basePos + float3(0.5 * cosA + sway, 1.2, 0.5 * sinA));
                    
                    v[0].uv = float2(0,0); v[1].uv = float2(1,0);
                    v[2].uv = float2(0,1); v[3].uv = float2(1,1);

                    for (int i = 0; i < 4; i++) {
                        UNITY_TRANSFER_INSTANCE_ID(IN[0], v[i]);
                        triStream.Append(v[i]);
                    }
                    triStream.RestartStrip();
                }
            }

            fixed4 frag (g2f i) : SV_Target {
                UNITY_SETUP_INSTANCE_ID(i);
                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col.a - _Cutoff); // Xóa ô vuông đen
                return col;
            }
            ENDCG
        }
    }
}