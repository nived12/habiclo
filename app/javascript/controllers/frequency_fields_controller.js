import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["section"]

  connect() {
    this.update()
  }

  update() {
    const select = this.element.querySelector("[data-frequency-select]")
    if (!select) return
    const value = select.value
    this.sectionTargets.forEach(section => {
      const show = section.dataset.frequencyShowWhen
      section.hidden = show !== value
    })
  }

  toggleDay(event) {
    const btn = event.currentTarget
    const active = btn.dataset.active === "true"
    btn.dataset.active = active ? "false" : "true"
    btn.classList.toggle("day-btn--active", !active)
    // sync hidden input
    const input = btn.nextElementSibling
    if (input && input.type === "hidden") {
      input.disabled = active
    }
  }
}
