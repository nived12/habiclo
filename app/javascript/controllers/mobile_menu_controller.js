import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.menu = document.getElementById("mobile_menu")
    this.previousFocus = null
    this.boundKey = this.handleKey.bind(this)
    this.boundTurbo = this.close.bind(this)
    document.addEventListener("keydown", this.boundKey)
    document.addEventListener("turbo:before-cache", this.boundTurbo)
    this.close()
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKey)
    document.removeEventListener("turbo:before-cache", this.boundTurbo)
    document.body.style.overflow = ""
  }

  open() {
    if (!this.menu) return
    this.previousFocus = document.activeElement
    this.menu.classList.add("is-open")
    document.body.style.overflow = "hidden"
    this.setExpanded(true)
    this.menu.querySelector("a, button")?.focus()
  }

  close() {
    if (!this.menu) return
    const wasOpen = this.menu.classList.contains("is-open")
    this.menu.classList.remove("is-open")
    document.body.style.overflow = ""
    this.setExpanded(false)
    if (wasOpen) {
      this.previousFocus?.focus?.()
      this.previousFocus = null
    }
  }

  handleKey(e) {
    if (e.key === "Escape" && this.menu?.classList.contains("is-open")) {
      this.close()
    }
  }

  closeOnBackdrop(e) {
    if (e.target.classList.contains("mobile-menu-shroud")) this.close()
  }

  setExpanded(open) {
    document.querySelector("[aria-controls='mobile_menu']")?.setAttribute("aria-expanded", open ? "true" : "false")
  }
}
