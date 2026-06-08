class Admin::MetricsController < ApplicationController
  before_action :require_owner

  PERIODS        = [ 7, 30, 90 ].freeze
  DEFAULT_PERIOD = 30
  ADMIN_LIKE     = "/admin%".freeze

  def show
    parse_range

    @stats      = window_stats(@from, @to)
    @prev_stats = window_stats(@prev_from, @prev_to)

    @views_by_day = daily_views(@from, @to)
    @peak_day     = @views_by_day.values.max || 0
    @prev_total   = @prev_stats[:views]

    @top_pages   = top_pages_comparison
    @referrers   = referrers(@from, @to)
    @devices     = devices(@from, @to)
    @returning   = returning_signed_in(@from, @to)
    @funnel      = funnel(@from, @to)
    @paths       = available_paths
  end

  private

  # ---- range parsing -----------------------------------------------------

  def parse_range
    @path = params[:path].presence

    if params[:from].present? && params[:to].present?
      @from = parse_date(params[:from]) || Date.current - (DEFAULT_PERIOD - 1)
      @to   = parse_date(params[:to])   || Date.current
      @from, @to = @to, @from if @from > @to
      @period = nil
    else
      @period = PERIODS.include?(params[:period].to_i) ? params[:period].to_i : DEFAULT_PERIOD
      @to     = Date.current
      @from   = @to - (@period - 1)
    end

    @days      = (@to - @from).to_i + 1
    @prev_to   = @from - 1
    @prev_from = @prev_to - (@days - 1)
  end

  def parse_date(value)
    Date.parse(value)
  rescue ArgumentError, TypeError
    nil
  end

  # ---- scopes ------------------------------------------------------------

  def range_for(from, to)
    from.beginning_of_day..to.end_of_day
  end

  def views_scope(from, to, apply_path: true)
    scope = Ahoy::Event.where(name: "$view")
                       .where(time: range_for(from, to))
                       .where.not("properties->>'path' LIKE ?", ADMIN_LIKE)
    scope = scope.where("properties->>'path' = ?", @path) if apply_path && @path
    scope
  end

  def visits_scope(from, to)
    Ahoy::Visit.where(started_at: range_for(from, to))
  end

  # ---- aggregations ------------------------------------------------------

  def window_stats(from, to)
    views    = views_scope(from, to)
    total    = views.count
    sessions = visits_scope(from, to).count

    {
      views: total,
      sessions: sessions,
      views_per_session: sessions.positive? ? (total.to_f / sessions).round(1) : 0,
      uniques: views.distinct.count(Arel.sql("properties->>'visitor'")),
      bounce_rate: bounce_rate(from, to),
      auth_split: views.group(Arel.sql("properties->>'signed_in'")).count
    }
  end

  # Share of sessions with exactly one page view (single-page sessions).
  def bounce_rate(from, to)
    counts = views_scope(from, to, apply_path: false).group(:visit_id).count
    return 0 if counts.empty?

    single = counts.count { |_, c| c == 1 }
    (100.0 * single / counts.size).round
  end

  def daily_views(from, to)
    raw = views_scope(from, to).group(Arel.sql("DATE(time)")).count
    raw.transform_keys { |k| k.is_a?(Date) ? k : Date.parse(k.to_s) }
  end

  # Top pages this window vs the previous window → Δ% per endpoint.
  # Ignores the path filter so this list stays the navigator you pick from.
  def top_pages_comparison
    current = views_scope(@from, @to, apply_path: false).group(Arel.sql("properties->>'path'")).count
    previous = views_scope(@prev_from, @prev_to, apply_path: false).group(Arel.sql("properties->>'path'")).count

    current.sort_by { |_, c| -c }.first(15).map do |path, count|
      prev_count = previous[path] || 0
      [ path, count, prev_count, delta_pct(count, prev_count) ]
    end
  end

  def referrers(from, to)
    visits_scope(from, to).where.not(referring_domain: [ nil, "" ])
                          .group(:referring_domain).count
                          .sort_by { |_, c| -c }.first(8)
  end

  def devices(from, to)
    visits_scope(from, to).group(:device_type).count
                          .sort_by { |_, c| -c }
  end

  # Reliable retention signal available cookieless: signed-in users with >1 session.
  def returning_signed_in(from, to)
    counts = visits_scope(from, to).where.not(user_id: nil).group(:user_id).count
    { total: counts.size, returning: counts.count { |_, c| c > 1 } }
  end

  def funnel(from, to)
    range = range_for(from, to)
    [
      [ "Sessions",          visits_scope(from, to).count ],
      [ "Signed up",         Ahoy::Event.where(name: "Signed up", time: range).count ],
      [ "Created habit",     Ahoy::Event.where(name: "Created habit", time: range).count ],
      [ "Logged completion", Ahoy::Event.where(name: "Logged completion", time: range).count ]
    ]
  end

  def available_paths
    Ahoy::Event.where(name: "$view")
               .where.not("properties->>'path' LIKE ?", ADMIN_LIKE)
               .distinct.pluck(Arel.sql("properties->>'path'"))
               .compact.sort
  end

  # nil = no previous baseline (treat as "new" in the view).
  def delta_pct(current, previous)
    return if previous.zero?

    (100.0 * (current - previous) / previous).round
  end

  # ---- auth --------------------------------------------------------------

  def require_owner
    forbidden unless user_signed_in? && owner_emails.include?(current_user.email)
  end

  # Delegates to ApplicationHelper#owner_emails — single source of truth for OWNER_EMAILS parsing.
  def owner_emails
    helpers.owner_emails
  end
end
