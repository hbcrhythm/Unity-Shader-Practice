Shader "Practice6/Jade"
{
    Properties
    {
        _DiffuseColor("Diffuse Color", Color) = (0,0,0,0)
        _Opacity("Opacity", Range(0, 1)) = 0
        _AddColor("Add Color", Color) = (0,0,0,0)
        _ThicknessMap("Thickness Map", 2D) = "blick" {}

        [Header(BasePass)]
        _BasePassDistortion("Base Pass Distortion", Range(0, 1)) = 0.2
        _BasePassColor("Base Pass Color", Color) = (1,1,1,1)
        _BasePassPower("Base Pass Power", float) = 1 //对比度，亮的更亮
        _BasePassScale("Base Pass Scale", float) = 1

        [Header(AddPass)]
        _AddPassDistortion("Add Pass Distortion", Range(0, 1)) = 0.2
        _AddPassColor("Add Pass Color", Color) = (1,1,1,1)
        _AddPassPower("Add Pass Power", float) = 1 //对比度，亮的更亮
        _AddPassScale("Add Pass Scale", float) = 1        

        [Header(EnvReflect)]
        _EnvMap("Env Map", Cube) = "white" {}
        _EnvRotate("Env Rotate", Range(0, 360)) = 0
        _FresnelMin("Fresnel Min", Range(-2,2)) = 0
        _FresnelMax("Fresnel Max", Range(-2,2)) = 1
        _EnvIntensity("Env Intensity", float) = 1.0


    }

    SubShader
    {
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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 pos_world : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            sampler2D _ThicknessMap;
            float4 _DiffuseColor;
            float4 _LightColor0;
            float4 _AddColor;
            float _Opacity;


            samplerCUBE _EnvMap;
            float4 _EnvMap_HDR;
            float _EnvRotate;

            float4 _BasePassColor;
            float _BasePassDistortion;
            float _BasePassPower;
            float _BasePassScale;

            float _FresnelMin;
            float _FresnelMax;
            float _EnvIntensity;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos_world = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal); //不用这个unity_WorldToObject，用UnityObjectWorldNormal 也可以得到正确的结果
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 normal_dir = normalize(i.normal);
                float3 view_dir = normalize(_WorldSpaceCameraPos - i.pos_world.xyz);
                float3 light_dir = normalize(_WorldSpaceLightPos0.xyz);

                //diffuse
                float diff_term = max(0.0, dot(normal_dir, light_dir)) ;
                float3 diffuse_light_color = diff_term * _DiffuseColor.xyz * _LightColor0.xyz;

                //越上越亮
                float sky_sphere = (dot(normal_dir, float3(0,1,0)) + 1.0 ) * 0.5;                
                float3 sky_light = sky_sphere * _DiffuseColor.xyz;
                float final_diffuse = diffuse_light_color + sky_light * _Opacity + _AddColor;

                float3 back_dir = -normalize(light_dir + normal_dir * _BasePassDistortion); //加点法线扰动
                float VdotB = max(0.0, dot(view_dir, back_dir)); //视线看中的地方亮
                float backlight_term = max(0.0, pow(VdotB, _BasePassPower)) * _BasePassScale; 
                float thickness = 1.0 - tex2D(_ThicknessMap, i.uv).r; //厚度贴图，越暗的地方越透，所以要越亮
                float3 backlight = backlight_term * thickness * _LightColor0.xyz * _BasePassColor.xyz;


                //env map
                float3 reflect_dir   = reflect(-view_dir, normal_dir);

                half rad = _EnvRotate * UNITY_PI / 180.0f;
                float2x2 m_rotate = float2x2(cos(rad), -sin(rad), sin(rad), cos(rad));
                float2 dir_rotate = mul(m_rotate, reflect_dir.xz);
                reflect_dir = half3(dir_rotate.x, reflect_dir.y, dir_rotate.y);

                float4 cubemap_color = texCUBE(_EnvMap, reflect_dir);
                half3 env_color = DecodeHDR(cubemap_color, _EnvMap_HDR);

                //边缘光
                float fresnel = 1.0 - saturate(dot(normal_dir, view_dir));
                fresnel = smoothstep(_FresnelMin, _FresnelMax, fresnel);

                float3 final_env = env_color * fresnel * _EnvIntensity;

                float3 final_color = final_diffuse + final_env + backlight;

                return float4(final_color, 1.0);
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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 pos_world : TEXCOORD1;
                float3 normal : TEXCOORD2;
                LIGHTING_COORDS(3,4)
            };

            sampler2D _ThicknessMap;
            float4 _DiffuseColor;
            
            float4 _LightColor0;
            float4 _AddColor;
            float _Opacity;


            samplerCUBE _EnvMap;
            float4 _EnvMap_HDR;
            float _EnvRotate;

            float4 _AddPassColor;
            float _AddPassDistortion;
            float _AddPassPower;
            float _AddPassScale;

            float _FresnelMin;
            float _FresnelMax;
            float _EnvIntensity;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos_world = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal); //不用这个unity_WorldToObject，用UnityObjectWorldNormal 也可以得到正确的结果
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 normal_dir = normalize(i.normal);
                float3 view_dir = normalize(_WorldSpaceCameraPos - i.pos_world.xyz);

                float3 light_dir = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.pos_world.xyz, _WorldSpaceLightPos0.w));
                float attenuation = LIGHT_ATTENUATION(i);

                float3 back_dir = -normalize(light_dir + normal_dir * _AddPassDistortion); //加点法线扰动
                float VdotB = max(0.0, dot(view_dir, back_dir)); //视线看中的地方亮
                float backlight_term = max(0.0, pow(VdotB, _AddPassPower)) * _AddPassScale; 
                float thickness = 1.0 - tex2D(_ThicknessMap, i.uv).r; //厚度贴图，越暗的地方越透，所以要越亮
                float3 backlight = backlight_term * thickness * _LightColor0.xyz * _AddPassColor.xyz;

                float3 final_color = backlight;

                return float4(final_color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}