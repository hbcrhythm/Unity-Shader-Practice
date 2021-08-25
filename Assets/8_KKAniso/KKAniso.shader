Shader "Practice8/KKAniso"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SpecIntensity("Spec Intensity", Range(0.01, 5)) = 1.0
        _Shininess("_Shininess", Range(0.01, 1000)) = 1.0
        _ShiftOffset("_ShiftOffset", Range(-1, 1)) = 0
        _ShiftMap("ShiftMap", 2D) = "white" {}
        _NoiseIntensity("_NoiseIntensity", Float) = 1.0
        _FlowMap("_FlowMap", 2D) = "gray" {}  
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal_dir : TEXCOORD1;
                float3 tangent_dir : TEXCOORD2;
                float3 binormal_dir : TEXCOORD3;
                float3 pos_world : TEXCOORD4;
            };

            sampler2D _ShiftMap;
            float4 _ShiftMap_ST;
            sampler2D _FlowMap;

            float4 _LightColor0;
            float _SpecIntensity;
            float _Shininess;
            float _ShiftOffset;
            float _NoiseIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal_dir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject)).xyz;
                o.tangent_dir = normalize(mul(unity_ObjectToWorld, v.tangent).xyz);
                o.binormal_dir = normalize(cross(o.normal_dir, o.tangent_dir) * v.tangent.w);
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                half3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
                half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                half3 normal_dir = normalize(i.normal_dir);
                half3 binormal_dir = normalize(i.binormal_dir);
                half3 tangent_dir = normalize(i.tangent_dir);

                half3 half_dir = normalize(light_dir + view_dir);

                half3 flowmap = tex2D(_FlowMap, i.uv).rgb;
                half2 aniso_dir = flowmap.rg * 2.0 - 1.0;
                half shiftnoise = flowmap.b * 2.0 - 1.0;


                binormal_dir = normalize(tangent_dir * aniso_dir.y + binormal_dir * aniso_dir.x);

                half2 uv_shift = i.uv * _ShiftMap_ST.xy + _ShiftMap_ST.zw;
                // half shiftnoise = tex2D(_ShiftMap, uv_shift).r;
                shiftnoise = shiftnoise* _NoiseIntensity;
                half3 b_offset = normal_dir * (_ShiftOffset + shiftnoise);

                binormal_dir = normalize(binormal_dir + b_offset);

                half TdotH = dot(binormal_dir, half_dir);
                half sinTH = sqrt(1 - TdotH * TdotH);

                half3 spec_color = pow(max(0.0, sinTH), _Shininess) * _LightColor0.xyz * _SpecIntensity;

                // sample the texture
                return float4(spec_color, 1.0);
            }
            ENDCG
        }
    }
}
