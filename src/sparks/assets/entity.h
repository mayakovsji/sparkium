#pragma once
#include "memory"
#include "sparks/assets/material.h"
#include "sparks/assets/mesh.h"
#include "sparks/assets/model.h"

namespace sparks {
class Entity {
 public:
  float area_{};
  template <class ModelType>
  Entity(const ModelType &model,
         const Material &material,
         const glm::mat4 &transform = glm::mat4{1.0f}) {
    model_ = std::make_unique<ModelType>(model);
    material_ = material;
    transform_ = transform;
    name_ = model_->GetDefaultEntityName();
    area_ = 0.0f;
  }

  template <class ModelType>
  Entity(const ModelType &model,
         const Material &material,
         const glm::mat4 &transform,
         const std::string &name) {
    model_ = std::make_unique<ModelType>(model);
    material_ = material;
    transform_ = transform;
    name_ = name;
    area_ = 0.0f;
  }
  [[nodiscard]] const Model *GetModel() const;
  [[nodiscard]] glm::mat4 &GetTransformMatrix();
  [[nodiscard]] const glm::mat4 &GetTransformMatrix() const;
  [[nodiscard]] Material &GetMaterial();
  [[nodiscard]] const Material &GetMaterial() const;
  [[nodiscard]] const std::string &GetName() const;
  float &GetArea();

  float CalculateTriangleArea(const glm::vec3 &v1,
                              const glm::vec3 &v2,
                              const glm::vec3 &v3) const;

  float &CalculateArea() const;

 private:
  std::unique_ptr<Model> model_;
  Material material_{};
  glm::mat4 transform_{1.0f};
  std::string name_;
};
}  // namespace sparks
