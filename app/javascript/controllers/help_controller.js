import { Controller } from "@hotwired/stimulus"

// Help / onboarding panel. Mounted on <body>; the panel lives at #help_panel.
// Persistence: POST /help_acknowledgment sets user.help_seen_at (guests + signed-in).
// data-seen-value mirrors help_seen_at; localStorage bridges Turbo navigations before ack lands.
// ? or Shift+/ always reopens (independent of flag).
const STORAGE_KEY = "habiclo:help_seen"

export default class extends Controller {
  static values = {
    seen: Boolean,
    ackUrl: String
  }

  connect() {
    this.panel = document.getElementById("help_panel")
    if (this.panel && !this.hasBeenSeen()) this.show()
    this.boundKey = this.handleKey.bind(this)
    document.addEventListener("keydown", this.boundKey)
  }

  disconnect() { document.removeEventListener("keydown", this.boundKey) }

  handleKey(e) {
    if (this.isEditing(e.target)) return
    if (e.key === "?" || (e.shiftKey && e.key === "/")) {
      e.preventDefault()
      this.show()
    } else if (e.key === "Escape" && this.panel?.classList.contains("is-open")) {
      this.dismiss()
    }
  }

  open() { this.show() }

  show() {
    if (!this.panel) return
    this.panel.classList.add("is-open")
    document.body.style.overflow = "hidden"
  }

  dismiss() {
    this.markSeen()
    if (!this.panel) return
    this.panel.classList.remove("is-open")
    document.body.style.overflow = ""
  }

  hasBeenSeen() {
    if (this.seenValue) return true
    try { return localStorage.getItem(STORAGE_KEY) === "1" } catch (_) { return false }
  }

  markSeen() {
    try { localStorage.setItem(STORAGE_KEY, "1") } catch (_) {}
    if (this.hasAckUrlValue && this.ackUrlValue) {
      const csrf = document.querySelector('meta[name="csrf-token"]')?.content
      fetch(this.ackUrlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrf || "",
          "Accept": "application/json"
        },
        credentials: "same-origin"
      }).catch(() => {})
    }
  }

  isEditing(el) {
    if (!el) return false
    return ["INPUT", "TEXTAREA", "SELECT"].includes(el.tagName) || el.isContentEditable
  }
}
