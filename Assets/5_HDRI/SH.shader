Shader "Practice5/SH"
{
    Properties
    {
        _Tint("Tint", color) = (1,1,1,1)
        _Expose("Expose", float) = 1.0
        _NormalMap("Normal Map", 2D) = "bump" {}
        _AOMap("AO Map", 2D) = "white" {}
        _Rotate("Rotate", Range(0, 360)) = 0

        custom_SHAr("Custom SHAr", Vector) = (0, 0, 0, 0)
        custom_SHAg("Custom SHAg", Vector) = (0, 0, 0, 0)
        custom_SHAb("Custom SHAb", Vector) = (0, 0, 0, 0)
        custom_SHBr("Custom SHBr", Vector) = (0, 0, 0, 0)
        custom_SHBg("Custom SHBg", Vector) = (0, 0, 0, 0)
        custom_SHBb("Custom SHBb", Vector) = (0, 0, 0, 0)
        custom_SHC("Custom SHC", Vector) = (0, 0, 0, 1)

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
            
            float4 _Tint;

            float _Expose;

            sampler2D _NormalMap;
            float4 _NormalMap_ST;

            sampler2D _AOMap;
            float _Rotate;

            half4 custom_SHAr;
            half4 custom_SHAg;
            half4 custom_SHAb;
            half4 custom_SHBr;
            half4 custom_SHBg;
            half4 custom_SHBb;
            half4 custom_SHC;

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
                //SHEvalLinearL0L1
                half3 x;
                x.r = dot(custom_SHAr, normalForSH);
                x.g = dot(custom_SHAg, normalForSH);
                x.b = dot(custom_SHAb, normalForSH);

                //SHEvalLinearL2
                half3 x1, x2;
                // 4 of the quadratic (L2) polynomials
                half4 vB = normalForSH.xyzz * normalForSH.yzzx;
                x1.r = dot(custom_SHBr, vB);
                x1.g = dot(custom_SHBg, vB);
                x1.b = dot(custom_SHBb, vB);

                // Final (5th) quadratic (L2) polynomial
                half vC = normalForSH.x*normalForSH.x - normalForSH.y*normalForSH.y;
                x2 = custom_SHC.rgb * vC;

                float3 sh = max(float3(0.0, 0.0, 0.0), (x + x1 + x2));
                sh = pow(sh, 1.0 / 2.2);

                if (IsGammaSpace())
                    sh = pow(sh, 1.0 / 2.2);

                half3 env_color = sh;
                half ao = tex2D(_AOMap, i.uv).r;

                half3 finial_color = env_color * ao * _Tint.rgb * _Expose;
                
                return float4(finial_color, 1.0);

            }
            ENDCG
        }
    }
}
