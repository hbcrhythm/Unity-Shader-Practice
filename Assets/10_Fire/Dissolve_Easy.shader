// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissolve_Easy"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_Gradient("Gradient", 2D) = "white" {}
		_ChangeMount("ChangeMount", Range( 0 , 1)) = 0.5
		_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		_EdgeIntensity("EdgeIntensity", Float) = 1
		[Toggle(_MANUALCONTROL_ON)] _ManualControl("ManualControl", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _MANUALCONTROL_ON
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _EdgeColor;
		uniform float _EdgeIntensity;
		uniform sampler2D _Gradient;
		uniform float4 _Gradient_ST;
		uniform float _ChangeMount;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode2 = tex2D( _MainTex, uv_MainTex );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float mulTime33 = _Time.y * 0.2;
			#ifdef _MANUALCONTROL_ON
				float staticSwitch35 = _ChangeMount;
			#else
				float staticSwitch35 = frac( mulTime33 );
			#endif
			float Gradient29 = ( ( tex2D( _Gradient, uv_Gradient ).r - (-0.1823034 + (staticSwitch35 - 0.0) * (1.0 - -0.1823034) / (1.0 - 0.0)) ) / 0.1823034 );
			float clampResult20 = clamp( ( 1.0 - ( distance( Gradient29 , 0.5 ) / 0.1 ) ) , 0.0 , 1.0 );
			float4 lerpResult25 = lerp( tex2DNode2 , ( tex2DNode2 * _EdgeColor * _EdgeIntensity ) , clampResult20);
			o.Emission = lerpResult25.rgb;
			o.Alpha = 1;
			clip( ( tex2DNode2.a * step( 0.5 , Gradient29 ) ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
76;141;1796;850;2017.492;234.0889;1.659745;False;False
Node;AmplifyShaderEditor.CommentaryNode;28;-1769.684,188.9451;Inherit;False;1233.35;837.0918;Gradient;11;29;9;3;7;35;37;36;4;34;33;38;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;33;-1734.143,550.6235;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;34;-1540.143,549.6235;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1753.58,678.6832;Inherit;False;Property;_ChangeMount;ChangeMount;3;0;Create;True;0;0;0;False;0;False;0.5;0.435;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-1651.235,874.3002;Inherit;False;Constant;_Spread;Spread;7;0;Create;True;0;0;0;False;0;False;0.1823034;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;35;-1396.143,642.6235;Inherit;False;Property;_ManualControl;ManualControl;6;0;Create;True;0;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;37;-1373.648,770.3456;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;7;-1123.489,621.0129;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-1719.684,238.9449;Inherit;True;Property;_Gradient;Gradient;2;0;Create;True;0;0;0;False;0;False;-1;92c66a961158b0a4591863d606340519;92c66a961158b0a4591863d606340519;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;9;-969.2291,304.0733;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;38;-914.1124,788.2854;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;31;-426.9216,600.7955;Inherit;False;1250.4;405.2003;EdgeColor;6;15;20;18;16;17;14;EdgeColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-722.9509,579.783;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-262.2847,251.8079;Inherit;False;29;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-376.9216,764.9958;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;17.0784,889.9958;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;14;-190.9216,722.9958;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;16;163.0784,762.9958;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;27;-30.58953,-114.7022;Inherit;False;Property;_EdgeColor;EdgeColor;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.8396226,0.464597,0.1148541,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;18;329.8783,728.1958;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-429.1335,-196.9444;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;-1;608157e1a6762ba4ab97436e67340906;608157e1a6762ba4ab97436e67340906;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;24;24.88832,65.66594;Inherit;False;Property;_EdgeIntensity;EdgeIntensity;5;0;Create;True;0;0;0;False;0;False;1;0.72;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;8;35.06962,144.7802;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;20;569.4781,650.7955;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;269.3233,-116.1128;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;25;483.9988,-226.4651;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;319.0784,172.9958;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;807.9,-223.7001;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Dissolve_Easy;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;34;0;33;0
WireConnection;35;1;34;0
WireConnection;35;0;4;0
WireConnection;37;0;36;0
WireConnection;7;0;35;0
WireConnection;7;3;37;0
WireConnection;9;0;3;1
WireConnection;9;1;7;0
WireConnection;38;0;9;0
WireConnection;38;1;36;0
WireConnection;29;0;38;0
WireConnection;14;0;30;0
WireConnection;14;1;15;0
WireConnection;16;0;14;0
WireConnection;16;1;17;0
WireConnection;18;0;16;0
WireConnection;8;1;30;0
WireConnection;20;0;18;0
WireConnection;23;0;2;0
WireConnection;23;1;27;0
WireConnection;23;2;24;0
WireConnection;25;0;2;0
WireConnection;25;1;23;0
WireConnection;25;2;20;0
WireConnection;11;0;2;4
WireConnection;11;1;8;0
WireConnection;0;2;25;0
WireConnection;0;10;11;0
ASEEND*/
//CHKSM=37BF9210C7DBDE008506E673733E0C5F9857C338