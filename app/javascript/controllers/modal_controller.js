import { Controller } from "@hotwired/stimulus"

// Native <dialog> + Turbo Frame for in-page forms. Close on success via turbo:submit-end.
export default class extends Controller {
  static targets = ["dialog", "frame"]
  static values = { url: String }

  connect() {
    this.beforeCache = () => this.close()
    document.addEventListener("turbo:before-cache", this.beforeCache)
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.beforeCache)
  }

  // Named `show` (not `open`) to avoid confusion with `<dialog>.open` / native APIs.
  show(event) {
    event?.preventDefault()
    if (!this.hasDialogTarget) return

    this.dialogTarget.showModal()

    if (this.hasFrameTarget && this.hasUrlValue) {
      this.frameTarget.src = this.urlValue
    }
  }

  close() {
    if (!this.hasDialogTarget) return
    if (this.dialogTarget.open) this.dialogTarget.close()

    if (this.hasFrameTarget) {
      this.frameTarget.innerHTML = ""
      this.frameTarget.removeAttribute("src")
    }
  }

  // Clicks on the dialog backdrop close the modal; clicks inside the panel do not bubble as dialog target.
  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  afterSubmit(event) {
    if (event.detail.success !== true) return
    this.close()
  }
}
