import { describe, it, expect, beforeEach, afterEach, jest } from "@jest/globals"
import { Application } from "@hotwired/stimulus"
import ActivityDashboardController from "../../app/javascript/controllers/activity_dashboard_controller.js"

async function waitForStimulus() {
  await Promise.resolve()
  await Promise.resolve()
}

function mountFixture() {
  document.body.innerHTML = `
    <div data-controller="activity-dashboard" data-action="keydown@window->activity-dashboard#handleKeydown">
      <input data-activity-dashboard-target="searchInput" data-action="input->activity-dashboard#scheduleFilter" />
      <select data-activity-dashboard-target="authorFilter" data-action="change->activity-dashboard#filter">
        <option value="">All</option>
        <option value="Alice">Alice</option>
      </select>
      <p data-activity-dashboard-target="emptyState" class="hidden">No matches</p>

      <div data-activity-dashboard-target="count" data-value="10">0</div>
      <div data-activity-dashboard-target="timelineItem"></div>

      <article data-activity-dashboard-target="card" data-post-title="Hello world" data-post-body="Body text" data-post-author="Alice"></article>
      <article data-activity-dashboard-target="card" data-post-title="Second post" data-post-body="Other content" data-post-author="Bob"></article>

      <button id="preview" data-action="activity-dashboard#openPreview" data-preview-path="/posts/1?preview=1">Preview</button>
      <dialog data-activity-dashboard-target="dialog" data-action="click->activity-dashboard#closeOnBackdrop"></dialog>
      <turbo-frame data-activity-dashboard-target="frame"></turbo-frame>
    </div>
  `
}

describe("ActivityDashboardController", () => {
  let application

  beforeEach(() => {
    jest.useFakeTimers()
    application = Application.start()
    application.register("activity-dashboard", ActivityDashboardController)
  })

  afterEach(() => {
    if (application) application.stop()
    application = null
    document.body.innerHTML = ""
    jest.runOnlyPendingTimers()
    jest.useRealTimers()
  })

  it("filters cards by query and toggles empty state", async () => {
    mountFixture()
    await waitForStimulus()

    const root = document.querySelector("[data-controller='activity-dashboard']")
    const input = root.querySelector("[data-activity-dashboard-target='searchInput']")
    const cards = root.querySelectorAll("[data-activity-dashboard-target='card']")
    const empty = root.querySelector("[data-activity-dashboard-target='emptyState']")

    input.value = "hello"
    input.dispatchEvent(new Event("input", { bubbles: true }))
    jest.advanceTimersByTime(130)

    expect(cards[0].classList.contains("hidden")).toBe(false)
    expect(cards[1].classList.contains("hidden")).toBe(true)
    expect(empty.classList.contains("hidden")).toBe(true)

    input.value = "nomatch"
    input.dispatchEvent(new Event("input", { bubbles: true }))
    jest.advanceTimersByTime(130)
    expect(empty.classList.contains("hidden")).toBe(false)
  })

  it("opens preview modal and closes with transition cleanup", async () => {
    mountFixture()
    await waitForStimulus()

    const root = document.querySelector("[data-controller='activity-dashboard']")
    const previewButton = root.querySelector("#preview")
    const dialog = root.querySelector("dialog")
    const frame = root.querySelector("turbo-frame")

    previewButton.click()
    expect(dialog.open).toBe(true)
    expect(frame.src).toContain("/posts/1?preview=1")

    window.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape", bubbles: true }))
    jest.advanceTimersByTime(200)

    expect(dialog.open).toBe(false)
    expect(frame.hasAttribute("src")).toBe(false)
  })

  it("animates count and timeline classes on connect", async () => {
    const rafSpy = jest.spyOn(globalThis, "requestAnimationFrame").mockImplementation((cb) => {
      cb(1000)
      return 1
    })

    mountFixture()
    await waitForStimulus()

    const count = document.querySelector("[data-activity-dashboard-target='count']")
    const timelineItem = document.querySelector("[data-activity-dashboard-target='timelineItem']")

    expect(Number(count.textContent)).toBeGreaterThan(0)

    jest.advanceTimersByTime(100)
    expect(timelineItem.classList.contains("opacity-100")).toBe(true)
    rafSpy.mockRestore()
  })
})
