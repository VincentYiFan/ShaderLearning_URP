Shader "Custom/GhostShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_GhostColor("Ghost Color", Color) = (1,1,1,1) //��Ӱ��ɫ
		_Offset("Offset", Range(0, 2)) = 0 //��Ӱƫ�뱾λ�ľ���
		_GhostAlpha("Ghost Alpha", Range(0, 1)) = 1 //��Ӱ��͸����
		_ShakeLevel("Shake Level", Range(0, 2)) = 0 //��Ӱ�����ĳ̶�
		_ShakeSpeed("Shake Speed", Range(0, 50)) = 1 //��Ӱ���ƶ��ٶ�
		_ShakeDir("Shake Direction", Vector) = (0, 0, 1, 0) //��Ӱ�ƶ��ķ���
		_Control("Control", Range(0, 0.54)) = 0 //������Ʋ�Ӱ
	}
		SubShader
		{
			Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }

			Pass //��Ӱ
			{
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha

				CGPROGRAM
				#pragma vertex vert 
				#pragma fragment frag 

				#include "UnityCG.cginc"

				struct v2f
				{
					float4 vertex : SV_POSITION;
					float2 uv : TEXCOORD0;
				};

				sampler2D _MainTex;
				fixed4 _GhostColor;
				float _Offset;
				float _GhostAlpha;
				float _ShakeLevel;
				float _ShakeSpeed;
				float _Control;
				float4 _ShakeDir;

				v2f vert(appdata_base v)
				{
					float yOffset = 0.5 * (floor(v.vertex.x * 10) % 2);

					v2f o;
					v.vertex += _Offset * cos(_Time.y * _ShakeSpeed) * _ShakeDir * _Control; //ƫ��
					v.vertex += _ShakeLevel * yOffset * sin(_Time.y * _ShakeSpeed) * _ShakeDir * _Control; //����
					o.vertex = UnityObjectToClipPos(v.vertex);

					o.uv = v.texcoord;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					return fixed4(tex2D(_MainTex, i.uv).rgb * _GhostColor, _GhostAlpha);
				}

				ENDCG
			}

			Pass //��ͨ��ɫ
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					return tex2D(_MainTex, i.uv);
				}
				ENDCG
			}
		}
}