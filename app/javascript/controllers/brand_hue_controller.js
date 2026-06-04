import { Controller } from "@hotwired/stimulus"

// Reads the data-brand-hue-value attribute on connect and applies it.
// Wired to a range slider via change->brand-hue#update; persists on commit.
export default class extends Controller {
  static targets = ["slider", "swatch"]
  static values  = { url: String }

  connect() {
    if (this.hasSliderTarget) this.preview()
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
