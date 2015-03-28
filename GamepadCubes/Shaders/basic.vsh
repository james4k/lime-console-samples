//#include "gamma.fxh"
#include "common.fxh"

//--------------------------------------------------------------------------------------
// Vertex shader
//--------------------------------------------------------------------------------------
MATRIX_ORDER float4x4 matWVP : register(c0);

struct VS_IN
{
	float3 ObjPos : POSITION;
	float4 Color : COLOR;
};

struct VS_OUT
{
	float4 ProjPos : VS_OUT_POSITION;
	float4 Color : COLOR;
};

VS_OUT main( VS_IN In )
{
	VS_OUT Out;
	Out.ProjPos = mul( matWVP, float4( In.ObjPos, 1 ) );
	Out.Color = In.Color;
	//Out.Color.rgb = gammaToLinear(Out.Color.rgb);
	return Out;
}
