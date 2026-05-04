import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "searchInput",
    "authorFilter",
    "card",
    "count",
    "emptyState",
    "dialog",
    "frame",
    "timelineItem"
  ]

  static values = {
    defaultPreviewPath: String
  }

  connect() {
    this.filterDebounceTimer = null
    this.revealTimeline()
    this.animateCounts()
  }

  disconnect() {
    if (this.filterDebounceTimer) clearTimeout(this.filterDebounceTimer)
  }

  scheduleFilter() {
    if (this.filterDebounceTimer) clearTimeout(this.filterDebounceTimer)
    this.filterDebounceTimer = setTimeout(() => this.filter(), 120)
  }

  filter() {
    const query = this.searchInputTarget.value.toLowerCase().trim()
    const author = this.authorFilterTarget.value.toLowerCase().trim()
    let visibleCount = 0

    this.cardTargets.forEach((card) => {
      const title = (card.dataset.postTitle || "").toLowerCase()
      const body = (card.dataset.postBody || "").toLowerCase()
      const postAuthor = (card.dataset.postAuthor || "").toLowerCase()

      const matchesQuery = query.length === 0 || title.includes(query) || body.includes(query) || postAuthor.includes(query)
      const matchesAuthor = author.length === 0 || postAuthor === author
      const visible = matchesQuery && matchesAuthor

      card.classList.toggle("hidden", !visible)
      if (visible) visibleCount += 1
    })

    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.toggle("hidden", visibleCount > 0)
    }
  }

  clearFilters() {
    this.searchInputTarget.value = ""
    this.authorFilterTarget.value = ""
    this.filter()
  }

  openPreview(event) {
    event.preventDefault()
    const path = event.currentTarget.dataset.previewPath || this.defaultPreviewPathValue
    if (!path || !this.hasDialogTarget || !this.hasFrameTarget) return

    this.frameTarget.src = path
    this.dialogTarget.showModal()
    this.dialogTarget.classList.remove("opacity-0")
    this.dialogTarget.classList.add("opacity-100")
  }

  closePreview() {
    if (!this.hasDialogTarget) return

    this.dialogTarget.classList.remove("opacity-100")
    this.dialogTarget.classList.add("opacity-0")
    setTimeout(() => {
      if (this.dialogTarget.open) this.dialogTarget.close()
      if (this.hasFrameTarget) {
        this.frameTarget.innerHTML = ""
        this.frameTarget.removeAttribute("src")
      }
    }, 180)
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.closePreview()
  }

  handleKeydown(event) {
    if (event.key === "Escape" && this.hasDialogTarget && this.dialogTarget.open) {
      this.closePreview()
    }
  }

  revealTimeline() {
    this.timelineItemTargets.forEach((item, idx) => {
      item.classList.add("opacity-0", "translate-y-2")
      setTimeout(() => {
        item.classList.remove("opacity-0", "translate-y-2")
        item.classList.add("opacity-100", "translate-y-0")
      }, idx * 80)
    })
  }

  animateCounts() {
    this.countTargets.forEach((node) => {
      const finalValue = Number(node.dataset.value || 0)
      const durationMs = 600
      const start = performance.now()

      const tick = (now) => {
        const elapsed = now - start
        const progress = Math.min(elapsed / durationMs, 1)
        const value = Math.floor(finalValue * progress)
        node.textContent = String(value)

        if (progress < 1) requestAnimationFrame(tick)
      }

      requestAnimationFrame(tick)
    })
  }
}
