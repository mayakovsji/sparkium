
struct GlobalUniformObject {
  mat4 projection;
  mat4 camera;
  vec3 envmap_light_direction;
  int envmap_id;
  vec3 envmap_minor_color;
  float envmap_offset;
  vec3 envmap_major_color;
  int hover_id;
  int selected_id;
  int accumulated_sample;
  int num_samples;
  int num_bounces;
  float fov;
  float aperture;
  float focal_length;
  float clamp;
  float gamma;
  float aspect;
  int enable_depth;
  int enable_motion;
  vec3 dir_motion;
};

struct EntityUniformObject {
  mat4 model;
  float area;
};

struct ObjectInfo {
  uint vertex_offset;
  uint index_offset;
};
