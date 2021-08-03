Shader "Unlit/Role"
{
    Properties
    {
        [Header(BaseInfo)]
        _BaseMap ("Base Map", 2D) = "white" {}
        _CompMask ("Comp Mask", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}

        _MetalAdjust("Metal Adjust", Range(-1, 1)) = 0
        _RoughnessAdjust("Roughness Adjust", Range(-1, 1)) = 0

        [Header(Specular)]
        _SpecShininess("_Spec Shininess", Float) = 1


        [Header(SH)]
        [HideInInSpector]custom_SHAr("Custom SHAr", Vector) = (0, 0, 0, 0)
        [HideInInSpector]custom_SHAg("Custom SHAg", Vector) = (0, 0, 0, 0)
        [HideInInSpector]custom_SHAb("Custom SHAb", Vector) = (0, 0, 0, 0)
        [HideInInSpector]custom_SHBr("Custom SHBr", Vector) = (0, 0, 0, 0)
        [HideInInSpector]custom_SHBg("Custom SHBg", Vector) = (0, 0, 0, 0)
        [HideInInSpector]custom_SHBb("Custom SHBb", Vector) = (0, 0, 0, 0)
        [HideInInSpector]custom_SHC("Custom SHC", Vector) = (0, 0, 0, 1)

        _CubeMap("Cube Map", Cube) = "white" {}
        _Tint("Tint", Color) = (1,1,1,1) 
        _Expose("Expose", float) = 1.0

        [Header(SSS)]
        _SkinLUT("Skin LUT", 2D) = "white" {}
        _SSSOffset("SSS Offset", Range(-1, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 pos_world : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float3 tangent : TEXCOORD3;
                float3 binormal : TEXCOORD4;
                LIGHTING_COORDS(5, 6)
            };

            sampler2D _BaseMap;
            sampler2D _CompMask;
            sampler2D _NormalMap;
            samplerCUBE _CubeMap;
            float4 _CubeMap_HDR;
            sampler2D _SkinLUT;

            float4 _LightColor0;
            float4 _MainTex_ST;
            float4 _Tint;
            float _Expose;
            float _MetalAdjust;
            float _RoughnessAdjust;
            float _SSSOffset;
            float _SpecShininess;

            half4 custom_SHAr;
            half4 custom_SHAg;
            half4 custom_SHAb;
            half4 custom_SHBr;
            half4 custom_SHBg;
            half4 custom_SHBb;
            half4 custom_SHC;

            float3 custom_sh(float3 normal_dir)
            {
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

                return sh;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // o.uv = TRANSFORM_TEX(v.texcoord, _BaseMap);
                o.uv = v.texcoord;
                o.normal = mul(float4(v.normal, 1.0), unity_WorldToObject).xyz;
                o.tangent = mul(unity_ObjectToWorld, v.tangent).xyz;
                o.binormal = cross(o.normal, o.tangent) * v.tangent.w;
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                TRANSFER_VERTEX_TO_FRAGMENT(o);

                return o;
            }

            //L = La + Ld + Ls  = kaIa + kd(I/r^2)max(0, n · l) + ks(I/r^2)max(0, n · h)^p
            fixed4 frag (v2f i) : SV_Target
            {
                half4 albedo_color = tex2D(_BaseMap, i.uv);
                albedo_color = pow(albedo_color, 2.2);

                half4 comp_mask = tex2D(_CompMask, i.uv);

                half roughness = saturate(comp_mask.r + _RoughnessAdjust);
                half metal = saturate(comp_mask.g + _MetalAdjust);
                half skin_area = 1.0 - comp_mask.b;

                half3 base_color = albedo_color.rgb * (1 - metal);
                half3 spec_color = lerp(0.04, albedo_color.rbg, metal);

                half3 normal_data = UnpackNormal(tex2D(_NormalMap, i.uv));

                //dir

                half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                half3 normal_dir = normalize(i.normal);
                half3 tangent_dir = normalize(i.tangent);
                half3 binormal_dir = normalize(i.binormal);
                float3x3 TBN = float3x3(tangent_dir, binormal_dir, normal_dir);
                normal_dir = normalize(mul(normal_data.xyz, TBN));

                //light Info

                half3 light_dir = normalize(_WorldSpaceLightPos0.xyz);

                half atten = LIGHT_ATTENUATION(i);

                //Direct Diffuse 
                half diff_term = max(0.0, dot(normal_dir, light_dir));
                half half_lambert = (diff_term + 1.0) * 0.5;

                half3 common_diffuse = diff_term * _LightColor0.xyz * base_color.xyz * atten;

                half2 uv_lut = half2(diff_term * atten + _SSSOffset, 1.0);
                half3 lua_color = tex2D(_SkinLUT, uv_lut);

                half3 sss_diffuse = lua_color * base_color * half_lambert * _LightColor0.xyz;
                half3 direct_diffuse = lerp(common_diffuse, sss_diffuse, skin_area);

                //Direct Specular
                half3 half_dir = normalize(light_dir + view_dir);
                half NdotH = dot(normal_dir, half_dir);
                half smoothness = 1.0 - roughness;
                half shininess = lerp(1, _SpecShininess, smoothness);
                half spec_term = pow(max(0.0, NdotH), shininess);
                half3 direct_specular = spec_term * spec_color * _LightColor0.xyz * atten;

                //Indirect Diffuse 
                float Indirect_diffuse = custom_sh(normal_dir) * base_color * half_lambert;

                //Indirect Specular
                half3 reflect_dir = reflect(-view_dir, normal_dir);
                roughness = roughness * (1.7 - 0.7 * roughness);
                float mip_level = roughness * 6.0;
                half4 color_cubemap = texCUBElod(_CubeMap, float4(reflect_dir, mip_level));
                half3 env_color = DecodeHDR(color_cubemap, _CubeMap_HDR);
                half3 Indirect_specular = env_color * _Expose * spec_color * half_lambert;

                half3 final_color = direct_diffuse + direct_specular + Indirect_diffuse + Indirect_diffuse + Indirect_specular;
                
                final_color = pow(final_color, 1.0/2.2);

                return float4(final_color, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
