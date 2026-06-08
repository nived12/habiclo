class Ahoy::Store < Ahoy::DatabaseStore
end

# set to true for JavaScript tracking
Ahoy.api = false

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = false

# Privacy-first: this app holds sensitive (medication) data, so we keep
# analytics anonymous — mask IPs, no visitor cookie (so no consent banner
# obligation), and don't persist location.
Ahoy.mask_ips = true
Ahoy.cookies = :none
