import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, date: String, habitId: String }

  connect() {
    if (this.element.dataset.completed === "true") {
      this._applyFill(true)
    }
  }

  async toggle(event) {
    event.preventDefault()
    event.stopImmediatePropagation()
    if (this._toggling) return
    this._toggling = true

    const wasDone = this._isDone()
    this._applyFill(!wasDone)
    this._syncLegend(!wasDone)

    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.content
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: { Accept: "application/json", "X-CSRF-Token": token || "" }
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      const data = await response.json()
      this._applyFill(data.completed)
      this.element.dataset.completed = data.completed.toString()
      this._syncLegend(data.completed)
    } catch (err) {
      console.error("ring toggle failed", err)
      this._applyFill(wasDone)
      this._syncLegend(wasDone)
    } finally {
      this._toggling = false
    }
  }

  _isDone() {
    return this.element.style.fill !== ""
  }

  _applyFill(done) {
    if (done) {
      const hue = window.getComputedStyle(this.element).getPropertyValue("--habit-hue").trim() || "85"
      this.element.style.fill = `oklch(56% 0.18 ${hue})`
      this.element.style.stroke = `oklch(46% 0.20 ${hue})`
      this.element.style.strokeWidth = "0.8"
    } else {
      this.element.style.fill = ""
      this.element.style.stroke = ""
      this.element.style.strokeWidth = ""
    }
  }

  _syncLegend(done) {
    const legendBtn = document.querySelector(
      `[data-legend-toggle-habit-id-value="${this.habitIdValue}"][data-legend-toggle-today-value="${this.dateValue}"]`
    )
    if (!legendBtn) return

    legendBtn.dataset.completed = done.toString()
    const ctrl = this.application.getControllerForElementAndIdentifier(legendBtn, "legend-toggle")
    if (ctrl) ctrl.completedValue = done
  }
}
