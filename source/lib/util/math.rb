def normalize(angle)
  two_pi = 2 * Math::PI
  angle = angle % two_pi
  angle -= two_pi if angle > Math::PI
  angle
end

def signed_angle_diff(to, from)
  diff = normalize(to - from)
  diff
end

def lerp_angle(a, b, t)
  delta = (b - a + 180) % 360 - 180
  a + delta * t
end