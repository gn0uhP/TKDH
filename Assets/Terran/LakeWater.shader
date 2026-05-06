Shader "Unlit/LakeWater"
{
    Properties
    {
        // Màu chính của nước hồ (nên chọn màu xanh lục đậm hoặc xanh lam đen)
        _BaseColor ("Base Lake Color", Color) = (0.1, 0.25, 0.2, 0.8)
        
        // Texture nhiễu để tạo gợn sóng (Normal Map hoặc Grayscale noise)
        _NoiseTex ("Ripple Noise Texture", 2D) = "white" {}
        
        // Tốc độ di chuyển của 2 lớp sóng giả
        _WaveSpeed1 ("Wave Speed 1 (XY)", Vector) = (0.01, 0.01, 0, 0)
        _WaveSpeed2 ("Wave Speed 2 (XY)", Vector) = (-0.015, 0.012, 0, 0)
        
        // Tỷ lệ của vân sóng (Tiling)
        _WaveScale1 ("Wave Scale 1", Float) = 2.0
        _WaveScale2 ("Wave Scale 2", Float) = 3.5
        
        // Cường độ gợn sóng (độ biến dạng ảnh)
        _RippleStrength ("Ripple Strength", Range(0, 0.05)) = 0.01
    }
    SubShader
    {
        // Đặt trong nhóm Transparent để có độ trong suốt
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
        
        // Tắt ghi vào ZBuffer để tránh lỗi hiển thị vật thể phía sau
        ZWrite Off
        // Chế độ trộn màu Alpha Blending tiêu chuẩn
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
                float4 screenPos : TEXCOORD1; // Dùng để tính toán biến dạng lớp nền
            };

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float4 _BaseColor;
            float4 _WaveSpeed1;
            float4 _WaveSpeed2;
            float _WaveScale1;
            float _WaveScale2;
            float _RippleStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                // Tính toán vị trí màn hình để phục vụ các hiệu ứng nâng cao sau này (nếu cần)
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Thời gian
                float t = _Time.y;

                // LAYER 1: Tính toán UV di chuyển cho lớp sóng 1
                float2 uv1 = i.uv * _WaveScale1 + _WaveSpeed1.xy * t;
                // Lấy giá trị nhiễu (dùng kênh R làm đại diện độ cao/biến dạng)
                float noise1 = tex2D(_NoiseTex, uv1).r;

                // LAYER 2: Tính toán UV di chuyển cho lớp sóng 2 (thường nhanh hơn và ngược hướng)
                float2 uv2 = i.uv * _WaveScale2 + _WaveSpeed2.xy * t;
                float noise2 = tex2D(_NoiseTex, uv2).r;

                // Trộn 2 lớp nhiễu để tạo sự hỗn loạn tự nhiên
                float combinedNoise = (noise1 + noise2) * 0.5;

                // Tạo biến dạng UV dựa trên nhiễu (để làm giả gợn sóng)
                // Chúng ta dịch chuyển UV một chút dựa trên giá trị noise
                float2 distortUV = i.uv + (combinedNoise - 0.5) * _RippleStrength;

                // Lấy màu từ texture tại vị trí UV đã bị biến dạng
                // Điều này làm cho texture "rung rinh"
                fixed4 finalNoiseCol = tex2D(_NoiseTex, distortUV);

                // Trộn màu nền nước hồ với texture gợn sóng
                // Chúng ta dùng finalNoiseCol.r để pha chút ánh sáng/tối từ texture vào màu nền
                fixed4 col = _BaseColor;
                
                // Thêm một chút độ sáng lăn tăn từ noise (tùy chọn)
                col.rgb += (combinedNoise - 0.5) * 0.1; 
                
                // Đảm bảo Alpha vẫn theo màu nền
                col.a = _BaseColor.a;

                return col;
            }
            ENDCG
        }
    }
}
