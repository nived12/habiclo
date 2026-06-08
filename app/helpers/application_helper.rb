module ApplicationHelper
  PASTEL_PRESETS = {
    "rose" => 12,
    "apricot" => 40,
    "sand" => 70,
    "sage" => 140,
    "mint" => 165,
    "sky" => 220,
    "lavender" => 280,
    "mauve" => 320
  }.freeze

  def habit_color(hue, lightness: 72, chroma: 0.09)
    "oklch(#{lightness}% #{chroma} #{hue})"
  end

  def closest_pastel_name(hue)
    return nil if hue.blank?

    PASTEL_PRESETS.min_by { |_, h| (h - hue.to_i).abs }&.first
  end

  def owner_view?
    return false unless user_signed_in?

    owner_emails.include?(current_user.email)
  end

  def owner_emails
    ENV.fetch("OWNER_EMAILS", "nivedvengilat@gmail.com,nivedvengilat@example.com")
       .split(",").map(&:strip)
  end
end
