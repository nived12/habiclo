import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["body", "chevron"]

  toggle() {
    const open = this.bodyTarget.classList.toggle("is-open")
    this.chevronTarget.classList.toggle("is-open", open)
    this.element.setAttribute("aria-expanded", open)
  }
}
