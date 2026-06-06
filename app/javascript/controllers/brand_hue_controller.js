import { Controller } from "@hotwired/stimulus"

// Reads the data-brand-hue-value attribute on connect and applies it.
// Wired to a range slider via change->brand-hue#update; persists on commit.
export default class extends Controller {
  static targets = ["slider", "swatch"]
  static values  = { url: String }

  connect() {
    if (this.hasSliderTarget) this.preview()
    this.boundChange = this.handleChange.bind(this)
    this.element.addEventListener("change", this.boundChange)
  }

  disconnect() {
    if (this.boundChange) this.element.removeEventListener("change", this.boundChange)
  }

  handleChange(event) {
    const input = event.target.closest('input[name="user[brand_hue]"]')
    if (!input) return
    const hue = parseInt(input.value, 10) || 25
    document.documentElement.style.setProperty("--brand-hue", hue)
  }

  preview() {
    const hue = parseInt(this.sliderTarget.value, 10) || 25
    document.documentElement.style.setProperty("--brand-hue", hue)
    if (this.hasSwatchTarget) this.swatchTarget.textContent = hue
  }

  async commit() {
    if (!this.urlValue || !this.hasSliderTarget) return
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    await fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "Content-Type": "application/x-www-form-urlencoded",
        "X-CSRF-Token": token || ""
      },
      body: `user[brand_hue]=${encodeURIComponent(this.sliderTarget.value)}`
    })
  }
}
