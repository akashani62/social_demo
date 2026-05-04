import { describe, it, expect, beforeEach, afterEach } from "@jest/globals"
import { Application } from "@hotwired/stimulus"
import AppearController from "../../app/javascript/controllers/appear_controller.js"

async function waitForStimulus() {
  await Promise.resolve()
  await Promise.resolve()
}

describe("AppearController", () => {
  let application

  beforeEach(() => {
    application = Application.start()
    application.register("appear", AppearController)
  })

  afterEach(() => {
    if (application) application.stop()
    application = null
    document.body.innerHTML = ""
  })

  it("adds then removes entrance utility classes after two animation frames", async () => {
    const el = document.createElement("div")
    el.setAttribute("data-controller", "appear")
    document.body.appendChild(el)
    await waitForStimulus()

    expect(el.classList.contains("opacity-0")).toBe(true)
    expect(el.classList.contains("translate-y-1")).toBe(true)

    globalThis.flushOneRequestAnimationFrame()
    expect(el.classList.contains("opacity-0")).toBe(true)

    globalThis.flushOneRequestAnimationFrame()
    expect(el.classList.contains("opacity-0")).toBe(false)
    expect(el.classList.contains("translate-y-1")).toBe(false)
  })
})
