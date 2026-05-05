Shader "Unlit/WaterSea"
{
    Properties
    {
        _MainTex ("Water Texture (Noise)", 2D) = "white" {}
        _Color ("Water Color", Color) = (0, 0.5, 1, 0.5)
        _SpeedX ("Speed X", Float) = 0.05
        _SpeedY ("Speed Y", Float) = 0.05
        _Distortion ("Distortion Strength", Range(0, 0.1)) = 0.02
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _SpeedX;
            float _SpeedY;
            float _Distortion;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                // Tạo hiệu ứng sóng nhấp nhô giả bằng cách dịch chuyển tọa độ UV
                float wave = sin(_Time.y + v.vertex.x) * _Distortion;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex) + wave;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Tính toán di chuyển texture theo thời gian
                float2 scrollingUV = i.uv;
                scrollingUV.x += _Time.y * _SpeedX;
                scrollingUV.y += _Time.y * _SpeedY;

                // Lấy màu từ texture đã di chuyển
                fixed4 col = tex2D(_MainTex, scrollingUV);
                
                // Trộn màu texture với màu nước mong muốn
                fixed4 finalColor = col * _Color;
                
                return finalColor;
            }
            ENDCG
        }
    }
}
