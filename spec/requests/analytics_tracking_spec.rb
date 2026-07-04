require 'rails_helper'

RSpec::Matchers.define_negated_matcher :not_change, :change

# Regression guard for the outage: /up rendered 200 HTML, so every healthcheck /
# uptime ping was logged as a $view + a new (cookieless) visit row, filling the DB.
RSpec.describe "Ahoy pageview tracking", type: :request do
  # Modern, non-bot UA so allow_browser lets it through and Ahoy doesn't bot-filter it.
  let(:headers) do
    { "HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " \
                           "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36" }
  end

  it "does not track the /up healthcheck" do
    expect { get "/up", headers: headers }
      .to not_change(Ahoy::Event, :count)
      .and not_change(Ahoy::Visit, :count)
  end

  it "tracks a normal content page as a $view" do
    expect { get root_path, headers: headers }
      .to change { Ahoy::Event.where(name: "$view").count }.by(1)
  end
end
