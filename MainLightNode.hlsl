void MainLightNode_float (float3 WorldPos, out float3 Direction, out half Attenuation, out float3 Color) {
	Color = 1;
	Direction = float3(-0.5, -.5, 0.5);
	Attenuation = 1;

	#ifdef SHADERGRAPH_PREVIEW
		Color = 1;
		Direction = float3(-0.5, -.5, 0.5);
		Attenuation = 1;
	#else
		#ifdef LIGHTWEIGHT_LIGHTING_INCLUDED
			Light mainLight = GetMainLight();
			Color = mainLight.color;
			Direction = mainLight.direction;

			float4 shadowCoord;
			#ifdef _SHADOWS_ENABLED
				#if SHADOWS_SCREEN
					float4 clipPos = TransformWorldToHClip(WorldPos);
					shadowCoord = ComputeShadowCoord(clipPos);
				#else
					shadowCoord = TransformWorldToShadowCoord(WorldPos);
				#endif
					
				mainLight.attenuation = MainLightRealtimeShadow(shadowCoord);
			#endif

			#if !defined(_MAIN_LIGHT_SHADOWS) || defined(_RECEIVE_SHADOWS_OFF)
				Attenuation = 1.0h;
			#endif

			#if SHADOWS_SCREEN
				Attenuation = SampleScreenSpaceShadowmap(shadowCoord);
			#else
				ShadowSamplingData shadowSamplingData = GetMainLightShadowSamplingData();
				half shadowStrength = GetMainLightShadowStrength();
				Attenuation = SampleShadowmap(shadowCoord, TEXTURE2D_ARGS(_MainLightShadowmapTexture, sampler_MainLightShadowmapTexture), shadowSamplingData, shadowStrength, false);
			#endif

			// Attenuation = mainLight.attenuation;
		#endif
	#endif
}
