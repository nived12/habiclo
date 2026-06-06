import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  guard(event) {
    if (this.element.dataset.clicked === "true") {
      event.preventDefault()
      event.stopImmediatePropagation()
      return
    }
    this.element.dataset.clicked = "true"
    this.element.classList.add("is-loading")
    this.element.setAttribute("aria-disabled", "true")
  }
}
