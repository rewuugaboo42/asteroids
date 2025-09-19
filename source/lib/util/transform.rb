require_relative 'math'

def sign(x)
  return -1 if x < 0
  return  1 if x > 0
  0
end

def rotate_toward(current_angle, target_angle, rot_speed)
  delta = signed_angle_diff(target_angle, current_angle)

  if delta.abs > rot_speed
    delta = @rot_speed * (delta < 0 ? -1 : 1)
  end

  new_angle = current_angle + delta

  normalize(new_angle)
end