Shader "Blinn-Phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _ParallaxMap ("ParallaxMap", 2D) = "balck" { }
        _NormalMap ("NormalMap", 2D) = "bump" { }

        _Parallax ("_Parallax", Float) = 2
        //镜面反射光泽度
        _SpecShininess ("Specular Shininess", Range(1.0, 100.0)) = 10.0
        //镜面反射光照系数
        _SpecIntensity ("Specular Intensity", Range(0.01, 5)) = 1.0

    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }
        LOD 100

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

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
                float4 posWorld : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float3 tangent : TEXCOORD3;
                float3 binnormal : TEXCOORD4;
                SHADOW_COORDS(5)

            };

            sampler2D _MainTex;
            sampler2D _ParallaxMap;
            sampler2D _NormalMap;

            float4 _MainTex_ST;
            float _SpecShininess;
            float _SpecIntensity;
            float4 _LightColor0;
            float _Parallax;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal = mul(float4(v.normal, 0.0), unity_WorldToObject).xyz;
                o.tangent = mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz;
                o.binnormal = cross(o.normal, o.tangent) * v.tangent.w;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                TRANSFER_SHADOW(o)
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half shadow = SHADOW_ATTENUATION(i);

                //specular = lightColor * SpecularColor*(max(V· R, 0)) ^shininess；
                //L = La + Ld + Ls  = kaIa + kd(I/r^2)max(0, n · l) + ks(I/r^2)max(0, n · h)^p
                half3 viewDir = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

                half3 normalDir = normalize(i.normal);
                half3 tangentDir = normalize(i.tangent);
                half3 binnormalDir = normalize(i.binnormal);
                float3x3 TBN = float3x3(tangentDir, binnormalDir, normalDir);
                half3 view_tangentspace = normalize(mul(TBN, viewDir));

                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                half2 uv_parallax = i.uv;

                for(int j = 0; j < 10; j++)
                {
                    half height = tex2D(_ParallaxMap, uv_parallax);
                    uv_parallax = uv_parallax - (0.5 - height) * view_tangentspace.xy * _Parallax * 0.01f;
                }

                half4 base_color = tex2D(_MainTex, uv_parallax);
                half3 normalMap = UnpackNormal(tex2D(_NormalMap, uv_parallax));

                normalDir = normalize(mul(normalMap.xyz, TBN));

                // diffuse
                half diffuse_term = min(shadow, max(0, dot(normalDir, lightDir)));
                half3 diffuse = _LightColor0.rgb * diffuse_term * base_color.rgb;
                //Phong Specular R=reflect(-L,N)

                //half3 reflectDir = reflect(-lightDir, normalDir);
                //float specular_term = pow(max(0, dot(reflectDir, viewDir)), _SpecShininess);
                //Blinn-Phong Specular
                half3 halfDir = normalize(viewDir + lightDir);
                half NDotH = dot(normalDir, halfDir);
                half specular_term = pow(max(0, NDotH), _SpecShininess);
                half3 specular = _LightColor0.rgb * specular_term * _SpecIntensity;

                //Ambient
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * base_color.rgb;

                half3 final_color = (ambient + diffuse + specular);

                return half4(final_color, 1.0);

            }
            ENDCG
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardAdd"
            }

            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

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
                float4 posWorld : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float3 tangent : TEXCOORD3;
                float3 binnormal : TEXCOORD4;
                LIGHTING_COORDS(5, 6)

            };

            sampler2D _MainTex;
            sampler2D _ParallaxMap;
            sampler2D _NormalMap;

            float4 _MainTex_ST;
            float _SpecShininess;
            float _SpecIntensity;
            float4 _LightColor0;
            float _Parallax;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal = mul(float4(v.normal, 0.0), unity_WorldToObject).xyz;
                o.tangent = mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz;
                o.binnormal = cross(o.normal, o.tangent) * v.tangent.w;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                //处理投影,判断灯光类型,从而计算出光照的衰减，cookies等
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half atten = LIGHT_ATTENUATION(i);

                //specular = lightColor * SpecularColor*(max(V· R, 0)) ^shininess；
                //L = La + Ld + Ls  = kaIa + kd(I/r^2)max(0, n · l) + ks(I/r^2)max(0, n · h)^p
                half3 viewDir = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

                half3 normalDir = normalize(i.normal);
                half3 tangentDir = normalize(i.tangent);
                half3 binnormalDir = normalize(i.binnormal);
                float3x3 TBN = float3x3(tangentDir, binnormalDir, normalDir);
                half3 view_tangentspace = normalize(mul(TBN, viewDir));

                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                half2 uv_parallax = i.uv;

                for(int j = 0; j < 10; j++)
                {
                    half height = tex2D(_ParallaxMap, uv_parallax);
                    uv_parallax = uv_parallax - (1 - height) * view_tangentspace.xy * _Parallax * 0.01f;
                }

                half4 base_color = tex2D(_MainTex, uv_parallax);
                half3 normalMap = UnpackNormal(tex2D(_NormalMap, uv_parallax));

                normalDir = normalize(mul(normalMap.xyz, TBN));

                // diffuse
                half diffuse_term = min(atten, max(0, dot(normalDir, lightDir)));
                half3 diffuse = _LightColor0.rgb * diffuse_term * base_color.rgb;
                //Phong Specular R=reflect(-L,N)

                //half3 reflectDir = reflect(-lightDir, normalDir);
                //float specular_term = pow(max(0, dot(reflectDir, viewDir)), _SpecShininess);
                //Blinn-Phong Specular
                half3 halfDir = normalize(viewDir + lightDir);
                half NDotH = dot(normalDir, halfDir);
                half specular_term = pow(max(0, NDotH), _SpecShininess);
                half3 specular = _LightColor0.rgb * specular_term * _SpecIntensity;

                half3 final_color = (diffuse + specular);

                return half4(final_color, 1.0);

            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}