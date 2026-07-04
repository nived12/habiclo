require 'rails_helper'

RSpec::Matchers.define_negated_matcher :not_change, :change

# Regression guard for the outage: a fully-seeded guest User was minted on every
# cookieless request. Bots (no cookie) drove 530k guests / ~21M rows and filled the
# volume. Bots must now create nothing; real browsers still get a guest.
RSpec.describe "Guest creation", type: :request do
  let(:browser_ua) do
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " \
      "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"
  end

  it "does not create a guest for a bot request" do
    expect { get "/", headers: { "HTTP_USER_AGENT" => "Googlebot/2.1 (+http://www.google.com/bot.html)" } }
      .to not_change(User, :count)
    expect(response).to have_http_status(:ok)
  end

  it "does not create a guest for a blank user agent" do
    expect { get "/", headers: { "HTTP_USER_AGENT" => "" } }
      .to not_change(User, :count)
  end

  it "creates one guest for a real browser with no cookie" do
    expect { get "/", headers: { "HTTP_USER_AGENT" => browser_ua } }
      .to change { User.where(guest: true).count }.by(1)
  end

  it "reuses the guest on a second request (does not create another)" do
    get "/", headers: { "HTTP_USER_AGENT" => browser_ua }
    expect { get "/", headers: { "HTTP_USER_AGENT" => browser_ua } }
      .to not_change(User, :count)
  end
end
