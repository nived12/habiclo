import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, done: Boolean }

  async toggle() {
    const wasDone = this.doneValue
    const nowDone = !wasDone
    this.doneValue = nowDone
    this._updateVisual(nowDone)

    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.content
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: { Accept: "application/json", "X-CSRF-Token": token || "" }
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
    } catch (err) {
      console.error("weekly cell toggle failed", err)
      this.doneValue = wasDone
      this._updateVisual(wasDone)
    }
  }

  _updateVisual(done) {
    this.element.dataset.done = done
    this.element.textContent = done ? "✓" : ""
  }
}
