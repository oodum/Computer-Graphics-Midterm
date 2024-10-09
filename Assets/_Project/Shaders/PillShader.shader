Shader "Unlit/PillShader" {
    Properties {
        _AmbientColor ("Color 1", Color) = (1,0,0,1)
        _MainTex ("Main Texture", 2D) = "white" {}

        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _Shininess ("Shininess", Range(0.01, 100)) = 50

        _ToonValue ("Toon Value", Range(1, 50)) = 10
    }
    SubShader {
        Tags {
            "RenderPipeline" = "UniversalPipeline" "RenderType"="Opaque"
        }

        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            float4 _AmbientColor;
            float4 _SpecularColor;
            float  _Shininess;
            float  _ToonValue;

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;

            struct appdata {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD1;
                float2 uv : TEXCOORD0;
                float3 viewDirectionWS : TEXCOORD2;
            };

            v2f vert(appdata IN)
            {
                v2f OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.normalWS = normalize(IN.normalOS);
                OUT.viewDirectionWS = normalize(GetCameraPositionWS() - TransformObjectToWorld(IN.positionOS));
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex); // I used TRANSFORM_TEX so I can adjust the scaling of the texture
                // In order to animate, simply scroll the texture coordinates
                // I chose the x direction to scroll horizontallyxz
                OUT.uv.x += _Time.y * 0.1;
                return OUT;
            }

            float4 frag(v2f IN) : SV_TARGET
            {
                // Get the texture colour
                float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);

                // Get lighting information
                Light  light = GetMainLight();
                float3 lightDirection = normalize(light.direction);

                // Ambient
                float3 ambient = float3(0.1, 0.1, 0.1) * _AmbientColor;

                // Diffuse
                float3 normal = normalize(IN.normalWS);
                float  ndotl = saturate(dot(normal, lightDirection));
                float3 diffuse = saturate(ndotl * light.color * _ToonValue) * texColor; // Multiply by a toon value, then saturate to clamp the colours

                // Specular
                float3 viewDirection = normalize(IN.viewDirectionWS);
                float3 reflectionDirection = reflect(-lightDirection, normal);
                float  specularFactor = pow(saturate(dot(reflectionDirection, viewDirection) - .02), _Shininess); // I subtracted a tiny amount from the dot product to make the specular smaller
                float3 specular = saturate(_SpecularColor * specularFactor * _ToonValue); // Multiply by a toon value, then saturate to clamp the colours

                return float4(ambient * texColor + diffuse + specular, 1);
            }
            ENDHLSL
        }
    }
}