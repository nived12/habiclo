import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    try {
      const tz = Intl.DateTimeFormat().resolvedOptions().timeZone
      if (tz) {
        document.cookie = `tz_iana=${encodeURIComponent(tz)};path=/;max-age=31536000;samesite=lax`
      }
    } catch (_) {}
  }
}
