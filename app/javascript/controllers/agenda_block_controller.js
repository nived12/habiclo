import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static values = { url: String, compact: Boolean }

  async toggle(event) {
    if (event.target.closest("[data-toggle-ignore]")) return
    event.preventDefault()
    if (!this.urlValue) return
    if (this.element.dataset.toggling === "true") return

    const wasCompleted = this.element.dataset.completed === "true"
    this.element.dataset.completed = wasCompleted ? "false" : "true"
    this.element.dataset.toggling = "true"

    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.content
      const url = this.urlValue + (this.urlValue.includes("?") ? "&" : "?") + "compact=" + this.compactValue
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": token || ""
        }
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      const html = await response.text()
      Turbo.renderStreamMessage(html)
    } catch (err) {
      console.error("toggle failed", err)
      this.element.dataset.completed = wasCompleted ? "true" : "false"
    } finally {
      this.element.dataset.toggling = "false"
    }
  }
}
