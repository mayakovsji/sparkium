#include "sparks/assets/entity.h"

namespace sparks {

const Model *Entity::GetModel() const {
  return model_.get();
}

glm::mat4 &Entity::GetTransformMatrix() {
  return transform_;
}

const glm::mat4 &Entity::GetTransformMatrix() const {
  return transform_;
}

Material &Entity::GetMaterial() {
  return material_;
}

const Material &Entity::GetMaterial() const {
  return material_;
}

const std::string &Entity::GetName() const {
  return name_;
}

float &Entity::GetArea() {
  if (area_ < 1e-4)
    area_ = CalculateArea();
  return area_;
}

float Entity::CalculateTriangleArea(const glm::vec3 &v1,
                            const glm::vec3 &v2,
                            const glm::vec3 &v3) const {
  // 使用海伦公式计算三角形的面积
  float a = glm::length(v2 - v1);
  float b = glm::length(v3 - v2);
  float c = glm::length(v1 - v3);
  float s = (a + b + c) / 2.0f;
  return glm::sqrt(s * (s - a) * (s - b) * (s - c));
}

float &Entity::CalculateArea() const {
  float area = 0.0f;
  auto indices_ = GetModel()->GetIndices();
  auto vertices_ = GetModel()->GetVertices();

  for (size_t i = 0; i < indices_.size(); i += 3) {
    // 获取三角形的顶点位置
    const glm::vec3 &v1 = vertices_[indices_[i]].position;
    const glm::vec3 &v2 = vertices_[indices_[i + 1]].position;
    const glm::vec3 &v3 = vertices_[indices_[i + 2]].position;

    // 计算三角形的面积并累加
    area += CalculateTriangleArea(v1, v2, v3);
  }

  return area;
}

}  // namespace sparks
