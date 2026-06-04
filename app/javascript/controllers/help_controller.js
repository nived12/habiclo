import { Controller } from "@hotwired/stimulus"

// Help / onboarding panel. Mounted on <body>; the panel lives at #help_panel.
// - Auto-opens on first visit (cookie not set).
// - Opens via the ? button or pressing "?".
// - Dismiss sets cookie habitower_help_seen=1 (1 year).
export default class extends Controller {
  static values = { seen: Boolean }

  connect() {
    this.panel = document.getElementById("help_panel")
    if (this.panel && !this.seenValue) this.show()
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

  open()    { this.show() }
  show()    {
    if (!this.panel) return
    this.panel.classList.add("is-open")
    document.body.style.overflow = "hidden"
  }
  dismiss() {
    if (!this.panel) return
    this.panel.classList.remove("is-open")
    document.body.style.overflow = ""
    document.cookie = "habitower_help_seen=1; max-age=31536000; path=/; samesite=lax"
  }

  isEditing(el) {
    if (!el) return false
    return ["INPUT", "TEXTAREA", "SELECT"].includes(el.tagName) || el.isContentEditable
  }
}
