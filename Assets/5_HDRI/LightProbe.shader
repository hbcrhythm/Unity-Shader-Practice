Shader "Practice5/LightProbe"
{
    Properties
    {
        _Tint("Tint", color) = (1,1,1,1)
        _Expose("Expose", float) = 1.0
        _NormalMap("Normal Map", 2D) = "bump" {}
        _AOMap("AO Map", 2D) = "white" {}
        _Rotate("Rotate", Range(0, 360)) = 0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

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
            
            float4 _Tint;

            float _Expose;

            sampler2D _NormalMap;
            float4 _NormalMap_ST;

            sampler2D _AOMap;
            float _Rotate;

            float3 RotateAround(float degree, float3 target)
            {
                float rad = degree * UNITY_PI / 180;
                float2x2 m_rotate = float2x2(cos(rad), -sin(rad),
                    sin(rad), cos(rad));
                float2 dir_rotate = mul(m_rotate, target.xz);
                target = float3(dir_rotate.x, target.y, dir_rotate.y);
                return target;
            }

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

                reflect_dir = RotateAround(_Rotate, reflect_dir);


                float4 normalForSH = float4(normal_dir, 1.0);

                half3 env_color = ShadeSH9(normalForSH);
                half ao = tex2D(_AOMap, i.uv).r;

                half3 finial_color = env_color * ao * _Tint.rgb * _Expose;
                
                return float4(finial_color, 1.0);

            }
            ENDCG
        }
    }
}
