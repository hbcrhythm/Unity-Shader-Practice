// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vine"
{
	Properties
	{
		_Plane_BaseColor("Plane_BaseColor", 2D) = "white" {}
		_Plane_NormalMap("Plane_NormalMap", 2D) = "bump" {}
		_Plane_Smoothness("Plane_Smoothness", 2D) = "white" {}
		_Vine_BaseColor("Vine_BaseColor", 2D) = "white" {}
		_Vine_NormalMap("Vine_NormalMap", 2D) = "bump" {}
		_Vine_Roughness("Vine_Roughness", 2D) = "white" {}
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Grow("Grow", Float) = 0
		_Offset("Offset", Float) = 0
		_Scale("Scale", Float) = 0
		_GrowMin("GrowMin", Range( 0 , 1)) = 0
		_GrowMax("GrowMax", Range( 0 , 1.5)) = 0.9
		_EndMin("EndMin", Range( 0 , 1)) = 0
		_EndMax("EndMax", Range( 0 , 1.5)) = 0.8765782
		_MatLerpFactor("MatLerpFactor", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _GrowMin;
		uniform float _GrowMax;
		uniform float _Grow;
		uniform float _EndMin;
		uniform float _EndMax;
		uniform float _Offset;
		uniform float _Scale;
		uniform sampler2D _Plane_NormalMap;
		uniform sampler2D _Plane_BaseColor;
		uniform float4 _Plane_BaseColor_ST;
		uniform sampler2D _Vine_NormalMap;
		uniform sampler2D _Vine_BaseColor;
		uniform float4 _Vine_BaseColor_ST;
		uniform float _MatLerpFactor;
		uniform sampler2D _Plane_Smoothness;
		uniform sampler2D _Vine_Roughness;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float temp_output_5_0 = ( v.texcoord.xy.y - _Grow );
			float smoothstepResult23 = smoothstep( _GrowMin , _GrowMax , temp_output_5_0);
			float smoothstepResult31 = smoothstep( _EndMin , _EndMax , v.texcoord.xy.y);
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( ( max( smoothstepResult23 , smoothstepResult31 ) * ( ase_vertexNormal * 0.01 * _Offset ) ) + ( ase_vertexNormal * _Scale ) );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Plane_BaseColor = i.uv_texcoord * _Plane_BaseColor_ST.xy + _Plane_BaseColor_ST.zw;
			float2 uv_Vine_BaseColor = i.uv_texcoord * _Vine_BaseColor_ST.xy + _Vine_BaseColor_ST.zw;
			float3 ase_worldPos = i.worldPos;
			float clampResult43 = clamp( ( ase_worldPos.y * _MatLerpFactor ) , 0.0 , 1.0 );
			float Lerpfactor45 = clampResult43;
			float3 lerpResult59 = lerp( UnpackNormal( tex2D( _Plane_NormalMap, uv_Plane_BaseColor ) ) , UnpackNormal( tex2D( _Vine_NormalMap, uv_Vine_BaseColor ) ) , Lerpfactor45);
			float3 normal61 = lerpResult59;
			o.Normal = normal61;
			float4 lerpResult56 = lerp( tex2D( _Plane_BaseColor, uv_Plane_BaseColor ) , tex2D( _Vine_BaseColor, uv_Vine_BaseColor ) , Lerpfactor45);
			float4 albedo58 = lerpResult56;
			o.Albedo = albedo58.rgb;
			float temp_output_5_0 = ( i.uv_texcoord.y - _Grow );
			float3 temp_cast_1 = (temp_output_5_0).xxx;
			o.Emission = temp_cast_1;
			float lerpResult60 = lerp( tex2D( _Plane_Smoothness, uv_Plane_BaseColor ).r , tex2D( _Vine_Roughness, uv_Vine_BaseColor ).r , Lerpfactor45);
			float smoothness62 = ( 1.0 - lerpResult60 );
			o.Smoothness = smoothness62;
			o.Alpha = 1;
			clip( ( 1.0 - temp_output_5_0 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
363;134;1551;748;1997.502;353.3497;1.742826;True;True
Node;AmplifyShaderEditor.CommentaryNode;47;-3784.634,-207.6553;Inherit;False;962.8191;380.8224;LerpFactor;5;39;42;41;43;45;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;39;-3734.634,-157.6552;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;42;-3728.815,57.16714;Inherit;False;Property;_MatLerpFactor;MatLerpFactor;14;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-3466.815,-66.8329;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;43;-3251.815,-65.83289;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1402.906,469.1122;Inherit;False;Property;_Grow;Grow;7;0;Create;True;0;0;0;False;0;False;0;0.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;54;-2098.391,-445.1536;Inherit;False;0;50;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-3008.814,-69.83289;Inherit;False;Lerpfactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;49;-2160.688,-1199.744;Inherit;False;0;36;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1416.358,278.6467;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-1119.906,1020.758;Inherit;False;Property;_EndMin;EndMin;12;0;Create;True;0;0;0;False;0;False;0;0.719;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1183.621,572.4317;Inherit;False;Property;_GrowMin;GrowMin;10;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-1454.886,810.3455;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-1185.78,659.7253;Inherit;False;Property;_GrowMax;GrowMax;11;0;Create;True;0;0;0;False;0;False;0.9;1.5;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-1281.074,-828.5525;Inherit;False;45;Lerpfactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;52;-1666.056,-237.734;Inherit;True;Property;_Vine_Roughness;Vine_Roughness;5;0;Create;True;0;0;0;False;0;False;-1;None;79722df8209c0d8419cec564ccf46330;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;38;-1679.431,-1032.743;Inherit;True;Property;_Plane_Smoothness;Plane_Smoothness;2;0;Create;True;0;0;0;False;0;False;-1;None;5b69da41deae6fc468efafdbfb3d62ac;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;30;-1115.928,1246.097;Inherit;False;Property;_EndMax;EndMax;13;0;Create;True;0;0;0;False;0;False;0.8765782;1.193;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;5;-1108.4,263.4909;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-628.3094,1355.627;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;51;-1669.846,-466.729;Inherit;True;Property;_Vine_NormalMap;Vine_NormalMap;4;0;Create;True;0;0;0;False;0;False;-1;None;8e0b8dd8a1fb4cd4784b58ca8409871e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;23;-851.2856,506.5455;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;11;-639.9052,1156.465;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;31;-726.9603,793.9615;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-628.8583,1580.171;Inherit;False;Property;_Offset;Offset;8;0;Create;True;0;0;0;False;0;False;0;-54.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;36;-1684.957,-1477.235;Inherit;True;Property;_Plane_BaseColor;Plane_BaseColor;0;0;Create;True;0;0;0;False;0;False;-1;None;c8461f3ab2ff47c489e4aeaf88a5e05d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;50;-1678.108,-685.6803;Inherit;True;Property;_Vine_BaseColor;Vine_BaseColor;3;0;Create;True;0;0;0;False;0;False;-1;None;af42bface2e2f5a4cbff1e6bada59ab0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;60;-667.6785,-474.0109;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;37;-1686.693,-1249.163;Inherit;True;Property;_Plane_NormalMap;Plane_NormalMap;1;0;Create;True;0;0;0;False;0;False;-1;None;c886840aa65cea14ab7494ed2314b46f;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;16;-329.8869,1438.237;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-255.5209,1208.754;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;33;-528.6898,610.8448;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-288.7989,1606.585;Inherit;False;Property;_Scale;Scale;9;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;59;-683.3257,-898.7118;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;63;-348.0255,-470.7915;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;56;-692.0335,-1310.344;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-359.5932,-1319.051;Inherit;False;albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-328.2623,-879.7573;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-68.67157,906.209;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;13.78504,1498.34;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-156.3229,-479.1968;Inherit;False;smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;223.565,965.5927;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-388.7648,103.3523;Inherit;False;61;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-394.7648,192.3523;Inherit;False;62;smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;8;-857.6736,272.8505;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-391.7648,13.35226;Inherit;False;58;albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Vine;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;6;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;41;0;39;2
WireConnection;41;1;42;0
WireConnection;43;0;41;0
WireConnection;45;0;43;0
WireConnection;52;1;54;0
WireConnection;38;1;49;0
WireConnection;5;0;2;2
WireConnection;5;1;3;0
WireConnection;51;1;54;0
WireConnection;23;0;5;0
WireConnection;23;1;24;0
WireConnection;23;2;25;0
WireConnection;31;0;28;2
WireConnection;31;1;29;0
WireConnection;31;2;30;0
WireConnection;36;1;49;0
WireConnection;50;1;54;0
WireConnection;60;0;38;1
WireConnection;60;1;52;1
WireConnection;60;2;55;0
WireConnection;37;1;49;0
WireConnection;12;0;11;0
WireConnection;12;1;13;0
WireConnection;12;2;14;0
WireConnection;33;0;23;0
WireConnection;33;1;31;0
WireConnection;59;0;37;0
WireConnection;59;1;51;0
WireConnection;59;2;55;0
WireConnection;63;0;60;0
WireConnection;56;0;36;0
WireConnection;56;1;50;0
WireConnection;56;2;55;0
WireConnection;58;0;56;0
WireConnection;61;0;59;0
WireConnection;21;0;33;0
WireConnection;21;1;12;0
WireConnection;19;0;16;0
WireConnection;19;1;18;0
WireConnection;62;0;63;0
WireConnection;20;0;21;0
WireConnection;20;1;19;0
WireConnection;8;0;5;0
WireConnection;0;0;64;0
WireConnection;0;1;65;0
WireConnection;0;2;5;0
WireConnection;0;4;66;0
WireConnection;0;10;8;0
WireConnection;0;11;20;0
ASEEND*/
//CHKSM=0220BF589EDC447BF82F7646FB42FE94C3599CEA