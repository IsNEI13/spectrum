#define DIFFUSE_MODEL 0 // [0 1]

//--//

float diffuse_lambertian(vec3 normal, vec3 light) {
	return max0(dot(normal, light)) / pi;
}
float diffuse_burley(vec3 view, vec3 normal, vec3 light, float roughness) {
	const vec2 efc = vec2(-51.0 / 151.0, 1.0) / pi;

	float NoL = max0(dot(normal, light));
	float VoH = dot(view, normalize(light + view));

	vec2 rs = (2.0 * roughness * (VoH * VoH + 0.25) - 1.0) * pow5(1.0 - vec2(NoL, max0(dot(normal, view)))) + 1.0;

	return NoL * rs.x * rs.y * (efc.x * roughness + efc.y);
}

#if DIFFUSE_MODEL == 1
#define diffuse(v, n, l, r) diffuse_burley(v, n, l, r)
#else
#define diffuse(v, n, l, r) diffuse_lambertian(n, l)
#endif

vec3 softShadow(vec3 position) {
	const vec2[12] offset = vec2[12](
		vec2(-0.5, 1.5),
		vec2( 0.5, 1.5),
		vec2(-1.5, 0.5),
		vec2(-0.5, 0.5),
		vec2( 0.5, 0.5),
		vec2( 1.5, 0.5),
		vec2(-1.5,-0.5),
		vec2(-0.5,-0.5),
		vec2( 0.5,-0.5),
		vec2( 1.5,-0.5),
		vec2(-0.5,-1.5),
		vec2( 0.5,-1.5)
	);

	vec2 pixel = 1.0 / textureSize2D(shadowtex1, 0);

	float result = 0.0;
	for (int i = 0; i < offset.length(); i++) {
		result += textureShadow(shadowtex1, position + vec3(offset[i] * pixel, 0.0));
	}
	result /= offset.length();

	return vec3(result * result);
}
vec3 shadows(vec3 position) {
	position = mat3(modelViewShadow) * position + modelViewShadow[3].xyz;
	vec3 normal = normalize(cross(dFdx(position), dFdy(position)));
	position = vec3(projectionShadow[0].x, projectionShadow[1].y, projectionShadow[2].z) * position + projectionShadow[3].xyz;

	float distortFactor = shadows_calculateDistortionCoeff(position.xy);

	position.xy *= distortFactor;
	position = position * 0.5 + 0.5;

	#if SHADOWS_MODE == 1
	return softShadow(position);
	#else
	float result = textureShadow(shadowtex1, position);
	return vec3(result * result * (-2.0 * result + 3.0));
	#endif
}

float blockLight(float lightmap) {
	return lightmap / (pow2(-4.0 * lightmap + 4.0) + 1.0);
}
float skyLight(float lightmap, vec3 normal) {
	return (dot(normal, upVector) * 0.2 + 0.8) * lightmap / (pow2(-4.0 * lightmap + 4.0) + 1.0);
}

float handLight(mat3 position, vec3 normal) {
	// TODO: Make this accurate to standard block lighting

	if (heldBlockLightValue + heldBlockLightValue2 == 0) return 0.0;

	const mat2x3 handPosition = mat2x3(
		vec3( 1.4, -0.6, -1.0) * MC_HAND_DEPTH,
		vec3(-1.4, -0.6, -1.0) * MC_HAND_DEPTH
	);

	mat2x3 lightVector = handPosition - mat2x3(position[1], position[1]);

	vec2 dist = clamp01((vec2(heldBlockLightValue, heldBlockLightValue2) - vec2(length(lightVector[0]), length(lightVector[1]))) * 0.0625);
	vec2 lm   = dist / (pow2(-4.0 * dist + 4.0) + 1.0);

	lm *= vec2(
		diffuse(normalize(position[1]), normal, normalize(lightVector[0]), 0.0),
		diffuse(normalize(position[1]), normal, normalize(lightVector[1]), 0.0)
	) * pi;

	return lm.x + lm.y;
}

vec3 calculateLighting(mat3 position, vec3 normal, vec2 lightmap, material mat, out vec3 sunVisibility) {
	#if PROGRAM != PROGRAM_WATER && (CAUSTICS_SAMPLES > 0 || RSM_SAMPLES > 0)
	vec4 filtered = bilateralResample(normal, position[1].z);
	#endif

	sunVisibility = shadows(position[2]);

	vec3
	shadowLight  = sunVisibility;
	shadowLight *= lightmap.y * lightmap.y;
	shadowLight *= mix(diffuse(normalize(position[1]), normal, shadowLightVector, mat.roughness), 1.0 / pi, mat.subsurface);
	#if PROGRAM != PROGRAM_WATER && CAUSTICS_SAMPLES > 0
	shadowLight *= filtered.a;
	#endif

	float skyLight = skyLight(lightmap.y, normal);

	float
	blockLight  = blockLight(lightmap.x);
	blockLight += handLight(position, normal);

	vec3
	lighting  = shadowLightColor * shadowLight;
	lighting += skyLightColor * skyLight;
	lighting += blockLightColor * blockLight;
	#if PROGRAM != PROGRAM_WATER && RSM_SAMPLES > 0
	lighting += filtered.rgb;
	#endif

	return lighting;
}
