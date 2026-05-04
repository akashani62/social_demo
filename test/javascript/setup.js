import { jest } from "@jest/globals"

// jsdom has no real <dialog> top layer; mirror open/close enough for our controller.
if (!HTMLDialogElement.prototype.showModal) {
  Object.defineProperty(HTMLDialogElement.prototype, "open", {
    get() {
      return this.hasAttribute("open")
    },
    configurable: true
  })

  HTMLDialogElement.prototype.showModal = function showModal() {
    this.setAttribute("open", "")
  }

  HTMLDialogElement.prototype.close = function close() {
    this.removeAttribute("open")
  }
}

// Deterministic rAF: one flush runs one queued callback (nested rAF needs two flushes).
const rafQueue = []
globalThis.requestAnimationFrame = (cb) => {
  rafQueue.push(cb)
  return rafQueue.length
}

globalThis.flushOneRequestAnimationFrame = () => {
  const fn = rafQueue.shift()
  if (fn) fn()
}

// Silence Stimulus debug noise in tests.
beforeEach(() => {
  jest.spyOn(console, "warn").mockImplementation(() => {})
})

afterEach(() => {
  jest.restoreAllMocks()
})
