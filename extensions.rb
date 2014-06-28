
class Matrix
  class << self
    include Math
    def x_rotate_matrix(theta)
      Matrix[[1,          0,           0],
             [0, cos(theta), -sin(theta)],
             [0, sin(theta),  cos(theta)]]
    end

    def y_rotate_matrix(theta)
      Matrix[[cos(theta),  0, sin(theta)],
             [0,           1,          0],
             [-sin(theta), 0, cos(theta)]]
    end

    def z_rotate_matrix(theta)
      Matrix[[cos(theta), -sin(theta),  0],
             [sin(theta),  cos(theta),  0],
             [0,                    0,  1]]
    end
  end
end

class Vector
  include Math

  def x_rotate(theta)
    Matrix.x_rotate_matrix(theta) * self
  end

  def y_rotate(theta)
    Matrix.y_rotate_matrix(theta) * self
  end

  def z_rotate(theta)
    Matrix.z_rotate_matrix(theta) * self
  end

  def angle_acute?(other)
    cos_theta = self.inner_product(other)
    (PI - acos(cos_theta)) < PI/2
  end
end
