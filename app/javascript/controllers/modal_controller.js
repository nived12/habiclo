import { Controller } from "@hotwired/stimulus"

// Lightweight modal dismiss controller for the log modal turbo frame.
// Clicking the shroud (not the inner card) dismisses; Esc dismisses.
export default class extends Controller {
  dismiss(event) {
    if (event) event.preventDefault()
    const frame = document.getElementById("log_modal")
    if (frame) frame.innerHTML = ""
  }

  dismissBackdrop(event) {
    if (event.target.classList.contains("log-modal-shroud")) this.dismiss()
  }
}
