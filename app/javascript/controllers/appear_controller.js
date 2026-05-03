import { Controller } from "@hotwired/stimulus"

// Subtle enter animation for Turbo Stream–inserted nodes (React-like polish).
export default class extends Controller {
  connect() {
    this.element.classList.add("opacity-0", "translate-y-1")
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        this.element.classList.remove("opacity-0", "translate-y-1")
      })
    })
  }
}
