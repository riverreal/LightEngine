#include "LightHelper.hlsli"

cbuffer LightBuffer
{
	DirectionalLight gDirLight;
	PointLight gPointLight;
	SpotLight gSpotLight;
	Material gMaterial;
	float3 gEyePosW;
	float pad;
};

cbuffer FogBuffer
{
	Fog gFog;
	//float pad;
};

Texture2D gDiffuseMap;
SamplerState samAnisotropic;

struct PixelInputType
{
	float4 position : SV_POSITION;
	float3 positionW : POSITION;
	float3 normalW : NORMAL;
	float2 tex : TEXCOORD;
};

float4 LightPixelShader(PixelInputType input) : SV_TARGET
{
	
	input.normalW = normalize(input.normalW);


	float3 toEye = gEyePosW - input.positionW;
	
	float distToEye = length(toEye);
	toEye /= distToEye;

	float4 texColor = float4(1, 1, 1, 1);
	texColor = gDiffuseMap.Sample(samAnisotropic, input.tex);

	float4 ambient = float4(0.0f, 0.0f, 0.0f, 0.0f);
	float4 diffuse = float4(0.0f, 0.0f, 0.0f, 0.0f);
	float4 specular = float4(0.0f, 0.0f, 0.0f, 0.0f);

	[unroll]
	/*
	float4 A = 0, D = 0, S = 0;
	
	ComputeDirectionalLight(gMaterial, gDirLight, input.normalW, toEye, A, D, S);
	ambient += A;
	diffuse += D;
	specular += S;

	ComputePointLight(gMaterial, gPointLight, input.positionW, input.normalW, toEye, A, D, S);
	ambient += A;
	diffuse += D;
	specular += S;

	ComputeSpotLight(gMaterial, gSpotLight, input.positionW, input.normalW, toEye, A, D, S);
	ambient += A;
	diffuse += D;
	specular += S;
	
	//Modelulate with late add
	float4 litColor =  texColor * (ambient + diffuse) + specular;
		
	*/

	
	

	float4 litColor;

	float lightIntensity = 1.0f;
	float att = 0.2;
	float ambientIntensity = 1.0f;
	float reflectionIntensity = 1.0f;

	float3 light = ComputeLight(gMaterial, gDirLight, input.normalW, toEye, texColor.rgb);
	float3 albedo = texColor.rgb - texColor.rgb * 1.0f;
	litColor.rgb = att * albedo * ambientIntensity + light * lightIntensity;
	
	//fog
	if(gFog.Enabled == true)
	{
		float fogLerp = saturate((distToEye - gFog.FogStart) / gFog.FogRange );
		litColor = lerp(litColor, gFog.FogColor, fogLerp);
	}

	litColor.a = gMaterial.Diffuse.a * texColor.a;
	
	return litColor;
	

	//return gDiffuseMap.Sample(samAnisotropic, input.positionW);
}