import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  select(event) {
    const hue = event.params.hue
    this.inputTarget.value = hue
    this.element.querySelectorAll(".swatch-picker-item").forEach((el) => {
      el.classList.toggle("is-selected", Number(el.dataset.swatchPickerHueParam) === Number(hue))
    })
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
