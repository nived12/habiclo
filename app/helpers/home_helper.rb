module HomeHelper
  # Builds an SVG arc path for a donut segment.
  # cx, cy   = center of the SVG
  # r_inner  = inner radius of the arc band
  # r_outer  = outer radius of the arc band
  # start_deg, end_deg = angles in degrees (0 = top, clockwise)
  # Returns a string suitable for SVG <path d="...">
  def arc_path(cx, cy, r_inner, r_outer, start_deg, end_deg)
    gap = 1.5 # degrees gap between segments
    s = start_deg + gap / 2.0
    e = end_deg   - gap / 2.0
    return "" if e <= s

    s_rad = (s - 90) * Math::PI / 180.0
    e_rad = (e - 90) * Math::PI / 180.0

    large_arc = (e - s) > 180 ? 1 : 0

    x1 = cx + r_outer * Math.cos(s_rad)
    y1 = cy + r_outer * Math.sin(s_rad)
    x2 = cx + r_outer * Math.cos(e_rad)
    y2 = cy + r_outer * Math.sin(e_rad)
    x3 = cx + r_inner * Math.cos(e_rad)
    y3 = cy + r_inner * Math.sin(e_rad)
    x4 = cx + r_inner * Math.cos(s_rad)
    y4 = cy + r_inner * Math.sin(s_rad)

    [
      "M #{x1.round(3)} #{y1.round(3)}",
      "A #{r_outer} #{r_outer} 0 #{large_arc} 1 #{x2.round(3)} #{y2.round(3)}",
      "L #{x3.round(3)} #{y3.round(3)}",
      "A #{r_inner} #{r_inner} 0 #{large_arc} 0 #{x4.round(3)} #{y4.round(3)}",
      "Z"
    ].join(" ")
  end
end
