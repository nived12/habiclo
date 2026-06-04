import { Controller } from "@hotwired/stimulus"

// Vim-ish navigation. h/l = prev/next week, t = today, n = new entry, m = month, w = week.
export default class extends Controller {
  connect() {
    this.boundHandle = this.handle.bind(this)
    document.addEventListener("keydown", this.boundHandle)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandle)
  }

  handle(e) {
    if (e.metaKey || e.ctrlKey || e.altKey) return
    if (this.isEditing(e.target)) return

    const path = window.location.pathname
    switch (e.key) {
      case "h": this.bump(-7); break
      case "l": this.bump(+7); break
      case "t": this.goto("/agenda/week"); break
      case "m": this.goto("/agenda/month"); break
      case "w": this.goto("/agenda/week"); break
      case "n":
        e.preventDefault()
        this.goto("/habits/new")
        break
      default:
        return
    }
  }

  bump(days) {
    const url = new URL(window.location.href)
    const on  = url.searchParams.get("on")
    const base = on ? new Date(on) : new Date()
    base.setDate(base.getDate() + days)
    const iso = base.toISOString().slice(0, 10)
    url.searchParams.set("on", iso)
    window.location.href = url.pathname + "?" + url.searchParams.toString()
  }

  goto(path) {
    window.Turbo ? window.Turbo.visit(path) : (window.location.href = path)
  }

  isEditing(el) {
    if (!el) return false
    const tag = el.tagName
    return tag === "INPUT" || tag === "TEXTAREA" || tag === "SELECT" || el.isContentEditable
  }
}
