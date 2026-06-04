import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, selector: String, confirm: String }

  async destroy(event) {
    event.preventDefault()
    event.stopImmediatePropagation()
    if (this.confirmValue && !confirm(this.confirmValue)) return

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    const response = await fetch(this.urlValue, {
      method: "DELETE",
      headers: { "X-CSRF-Token": token || "", "Accept": "application/json" }
    })
    if (!response.ok) {
      console.error("destroy failed", response.status)
      return
    }
    document.querySelectorAll(this.selectorValue).forEach(el => el.remove())
  }
}
