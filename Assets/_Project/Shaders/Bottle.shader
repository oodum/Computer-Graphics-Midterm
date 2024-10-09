Shader "Unlit/Bottle" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0.5, 8)) = 3
    }
    SubShader {
        // These tags are necessary for the transparency to work
        Tags {
            "RenderType"="Transparent" "Queue"="Transparent" "RenderPipeline" = "UniversalPipeline"
        }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            float4 _Color;
            float4 _RimColor;
            float _RimPower;

            struct appdata {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };

            struct v2f {
                float4 positionCS : SV_POSITION;
                float3 viewDirectionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
            };


            v2f vert(appdata IN)
            {
                v2f OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));
                OUT.viewDirectionWS = normalize(GetCameraPositionWS() - TransformObjectToWorld(IN.positionOS));
                return OUT;
            }

            float4 frag(v2f IN) : SV_Target
            {
                // Basic rim lighting
                float3 normal = normalize(IN.normalWS);
                float3 viewDirection = normalize(IN.viewDirectionWS);
                float rimFactor = 1 - saturate(dot(normal, viewDirection));
                float rim = pow(rimFactor, _RimPower);

                return float4(_Color.rgb + _RimColor.rgb * rim, _Color.a); // Because color.a is the alpha, the transparency depends on the main color's alpha, and isn't there by default
            }
            ENDHLSL
        }
    }
}