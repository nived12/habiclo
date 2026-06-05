import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, completed: Boolean, habitId: String, today: String, hue: Number }

  async toggle(event) {
    if (event) { event.preventDefault(); event.stopImmediatePropagation() }
    if (this._toggling) return
    this._toggling = true

    const wasCompleted = this.completedValue
    const nowCompleted = !wasCompleted

    this.completedValue = nowCompleted
    this.element.dataset.completed = nowCompleted.toString()
    this._syncRingSegment(nowCompleted)

    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.content
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: { Accept: "application/json", "X-CSRF-Token": token || "" }
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      const data = await response.json()
      this.completedValue = data.completed
      this.element.dataset.completed = data.completed.toString()
      this._syncRingSegment(data.completed)
    } catch (err) {
      console.error("legend toggle failed", err)
      this.completedValue = wasCompleted
      this.element.dataset.completed = wasCompleted.toString()
      this._syncRingSegment(wasCompleted)
    } finally {
      this._toggling = false
    }
  }

  _syncRingSegment(done) {
    const seg = document.getElementById(`ring_seg_${this.habitIdValue}_${this.todayValue}`)
    if (!seg) return
    seg.dataset.completed = done.toString()
    if (done) {
      const hue = window.getComputedStyle(seg).getPropertyValue("--habit-hue").trim() || this.hueValue || "85"
      seg.style.fill = `oklch(72% 0.09 ${hue})`
      seg.style.stroke = `oklch(60% 0.08 ${hue})`
      seg.style.strokeWidth = "0.8"
    } else {
      seg.style.fill = ""
      seg.style.stroke = ""
      seg.style.strokeWidth = ""
    }
  }
}
