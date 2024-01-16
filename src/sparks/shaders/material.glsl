#include "constants.glsl"
#include "random.glsl"
struct Material {
  vec3 albedo_color;
  int albedo_texture_id;
  vec3 emission;
  float emission_strength;
  float alpha;
  uint material_type;
};

#define MATERIAL_TYPE_LAMBERTIAN 0
#define MATERIAL_TYPE_SPECULAR 1
#define MATERIAL_TYPE_TRANSMISSIVE 2
#define MATERIAL_TYPE_PRINCIPLED 3
#define MATERIAL_TYPE_EMISSION 4
#define MATERIAL_TYPE_MICROSURFACE 5
#define MATERIAL_TYPE_SMOKE 6


float ior = 10.5;
vec3 Ks = vec3(0.45, 0.45, 0.45);
float Roughness = 0.0;

float fresnel(vec3 I, vec3 n, float ior) 
    {
        float cosi = clamp(-1, 1, dot(I, n));
        float etai = 1, etat = ior, tmp;
        if (cosi > 0.0) { tmp = etai; etai = etat; etat = tmp;}
        float sint = etai / etat * sqrt(max(0.0, 1.0 - cosi * cosi));
        if (sint >= 1.0) {
            return 1.0;
        }
        else {
            float cost = sqrt(max(0.0, 1.0 - sint * sint));
            cosi = abs(cosi);
            float Rs = ((etat * cosi) - (etai * cost)) / ((etat * cosi) + (etai * cost));
            float Rp = ((etai * cosi) - (etat * cost)) / ((etai * cosi) + (etat * cost));
            return (Rs * Rs + Rp * Rp) / 2.0;
        }
    }

float pdf(vec3 dir_in, vec3 dir_out, vec3 n, Material material, uint type){
	float cos_on = dot(dir_out, n);
	if (material.material_type != MATERIAL_TYPE_MICROSURFACE) 
		return (cos_on * INV_PI);
	if (type == 0)
		return (cos_on * INV_PI);
	else {
		vec3 h = normalize(-dir_in + dir_out);
		float cos_sita = dot(h, n), D;
    float divisor = (PI * pow(1.0 + cos_sita * cos_sita * (Roughness * Roughness - 1), 2));
    if (divisor < 1e-6)
      D = 1.0;
    else 
      D = (Roughness * Roughness) / divisor;
		return D * cos_on;
	}
}

vec3 SampleReflect (vec3 direction, vec3 n, Material material, uint type){
	if (material.material_type != MATERIAL_TYPE_MICROSURFACE || type == 0) {
		float cos_theta = RandomFloat(); 
    float phi = 2.0 * PI * RandomFloat(); 
    float x = cos(phi) * sqrt(1 - cos_theta * cos_theta);
    float y = sin(phi) * sqrt(1 - cos_theta * cos_theta);
    float z = cos_theta;
    return normalize(vec3(x, y, z));
	} else {
    float u = RandomFloat(), phi = 2 * PI * RandomFloat();
		float z = sqrt( (1.0 - u) / ((Roughness * Roughness - 1) * u + 1));
		float r = sqrt(1 - z * z); 
		return normalize(vec3(r * cos(phi), r * sin(phi), z));
  }
}

vec3 MaterialReflect (vec3 dir_in, vec3 dir_out, vec3 n, Material material, vec3 albedo_record){
  uint material_type = material.material_type;
  switch(material_type){
    case MATERIAL_TYPE_LAMBERTIAN: {
      return albedo_record / PI;
    }
    case MATERIAL_TYPE_SPECULAR: {
      return albedo_record * max(pow(dot(reflect(dir_in, n), dir_out), 10), 0.0);
    }
    
    case MATERIAL_TYPE_MICROSURFACE: {

      float cosalpha = dot(n, dir_out);
        if (cosalpha > 0.0f) {
          
          // calculate the contribution of Microfacet model
          float F, G, D;
          F = fresnel(dir_in, n, ior);
          
          vec3 h = normalize(-dir_in + dir_out);
          
          float A_wi, A_wo;
          A_wi = (-1 + sqrt(1 + Roughness * Roughness * pow(tan(acos(dot(-dir_in, n))), 2))) / 2;
          A_wo = (-1 + sqrt(1 + Roughness * Roughness * pow(tan(acos(dot(dir_out, n))), 2))) / 2;
          float divisor = (1 + A_wi + A_wo);
          if (divisor < 1e-6)
            G = 1.0;
          else
            G = 1.0 / divisor;
      
          float cos_sita = dot(h, n);
          divisor = (PI * pow(1.0 + cos_sita * cos_sita * (Roughness * Roughness - 1), 2));
          if (divisor < 1e-6)
            D = 1.0;
          else 
            D = (Roughness * Roughness) / divisor;
          
          // energy balance
          vec3 diffuse = (vec3(1.0f) - F) * albedo_record / PI;
          vec3 specular;
          divisor= ((4 * (dot(n, -dir_in)) * (dot(n, dir_out))));
          if (divisor < 1e-6)
            specular = vec3(1.0);
          else
            specular = Ks * vec3(F * G * D / divisor);
          return diffuse + specular;
				}
        else
          return vec3(0.0f);
        
    }

  }
  return vec3(0.0);
}
