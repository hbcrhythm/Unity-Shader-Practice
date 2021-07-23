Shader "lit/Phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        //镜面反射光泽度
        _SpecShininess("Specular Shininess", Range(1.0, 100.0)) = 10.0
        //镜面反射光照系数
        _SpecIntensity("Specular Intensity", Range(0.01, 5)) = 1.0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{ "LightMode" = "ForwarBase"}


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
                float4 position : SV_POSITION;
                float4 posWorld : TEXCOORD1;
                float3 normal : TEXCOORD2;

            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _SpecShininess;
            float _SpecIntensity;
            float4 _LightColor0;

            v2f vert (appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal = mul(float4(v.normal, 0.0), unity_WorldToObject).xyz;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {

                // sample the texture
                //specular = lightColor * SpecularColor*(max(V· R, 0)) ^shininess；
                //L = La + Ld + Ls  = kaIa + kd(I/r^2)max(0, n · l) + ks(I/r^2)max(0, n · h)^p

                half4 col = tex2D(_MainTex, i.uv);
                
                half3 normalDir = normalize(i.normal);
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                half3 viewDir = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

                half3 halfDir = normalize(viewDir + lightDir);

                half diffuse_term = max(0, dot(normalDir, lightDir));
                half3 diffuse = _LightColor0.rgb * diffuse_term;

                //Phong Specular R=reflect(-L,N)
//                half3 reflectDir = reflect(-lightDir, normalDir);
//                float specular_term = pow(max(0, dot(reflectDir, viewDir)), _SpecShininess);
                //Blinn-Phong Specular
                half NDotH = dot(normalDir, halfDir);
                half specular_term = pow(max(0, NDotH), _SpecShininess);
                half3 specular = _LightColor0.rgb * specular_term * _SpecIntensity;

                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                half3 final_color = ambient + diffuse + specular; 

                return half4(diffuse,1.0);

            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
