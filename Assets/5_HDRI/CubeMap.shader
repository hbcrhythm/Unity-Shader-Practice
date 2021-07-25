Shader "Practice/CubeMap"
{
    Properties
    {
        _CubeMap("Cube Map", Cube) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _AOMap("AO Map", 2D) = "white" {}

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
                float4 pos : SV_POSITION;
                float3 normal_world : TEXCOORD1;
                float3 pos_world : TEXCOORD2;
                float3 tangent_world : TEXCOORD3;
                float3 binormal_world : TEXCOORD4;

            };
            
            samplerCUBE _CubeMap;
            float4 _CubeMap_HDR;      
            sampler2D _NormalMap;
            float4 _NormalMap_ST;

            sampler2D _AOMap;


            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _NormalMap_ST.xy + _NormalMap_ST.zw;
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal_world = mul(float4(v.normal, 0.0), unity_WorldToObject).xyz;
                o.tangent_world = mul(unity_ObjectToWorld, v.tangent).xyz;
                o.binormal_world = cross(o.normal_world, o.tangent_world) * v.tangent.w;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 normal_dir = normalize(i.normal_world);
                half3 tangent_dir = normalize(i.tangent_world);
                half3 binormal_dir = normalize(i.binormal_world);

                half3 normalData = UnpackNormal(tex2D(_NormalMap, i.uv));
                normal_dir = normalize(tangent_dir * normalData.x + binormal_dir * normalData.y + normal_dir * normalData.z);
                half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                half3 reflect_dir = reflect(-view_dir, normal_dir);
                half4 color_cubeMap = texCUBE(_CubeMap, reflect_dir);
                half ao = tex2D(_AOMap, i.uv).r;

                half3 env_color = DecodeHDR(color_cubeMap, _CubeMap_HDR);
                half3 finial_color = env_color * ao;
                
                return float4(finial_color, 1.0);

            }
            ENDCG
        }
    }
}
