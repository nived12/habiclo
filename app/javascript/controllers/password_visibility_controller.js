import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "show", "hide"]

  toggle() {
    const revealed = this.inputTarget.type === "text"
    this.inputTarget.type = revealed ? "password" : "text"
    this.showTarget.classList.toggle("hidden", !revealed)
    this.hideTarget.classList.toggle("hidden", revealed)
  }
}
