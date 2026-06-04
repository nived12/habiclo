import { Controller } from "@hotwired/stimulus"

// Double-click an empty calendar cell to jump to the new-habit form pre-filled with that day + hour.
export default class extends Controller {
  static values = { on: String, hour: Number }

  connect() {
    this.bound = this.handle.bind(this)
    this.element.addEventListener("dblclick", this.bound)
  }

  disconnect() {
    this.element.removeEventListener("dblclick", this.bound)
  }

  handle(e) {
    if (e.target.closest(".agenda-block")) return
    const params = new URLSearchParams({
      "habit[scheduled_at_minute]": this.hourValue * 60,
      "on": this.onValue
    })
    const href = `/habits/new?${params}`
    window.Turbo ? window.Turbo.visit(href) : (window.location.href = href)
  }
}
