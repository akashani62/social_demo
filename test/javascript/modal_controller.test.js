import { describe, it, expect, beforeEach, afterEach, jest } from "@jest/globals"
import { Application } from "@hotwired/stimulus"
import ModalController from "../../app/javascript/controllers/modal_controller.js"

function mountFixture(html) {
  document.body.innerHTML = html
  return document.querySelector("[data-controller='modal']")
}

describe("ModalController", () => {
  let application

  beforeEach(() => {
    application = Application.start()
    application.register("modal", ModalController)
  })

  afterEach(() => {
    if (application) application.stop()
    application = null
    document.body.innerHTML = ""
  })

  it("show prevents default on the triggering event", () => {
    const root = mountFixture(`
      <div data-controller="modal" data-modal-url-value="/posts/new">
        <button type="button" data-action="click->modal#show">Open</button>
        <dialog data-modal-target="dialog">
          <div data-action="turbo:submit-end->modal#afterSubmit">
            <turbo-frame id="new_post_modal" data-modal-target="frame"></turbo-frame>
          </div>
        </dialog>
      </div>
    `)

    const btn = root.querySelector("button")
    const ev = new MouseEvent("click", { bubbles: true, cancelable: true })
    const spy = jest.spyOn(ev, "preventDefault")
    btn.dispatchEvent(ev)

    expect(spy).toHaveBeenCalled()
  })

  it("show opens the dialog and assigns the turbo frame src from the url value", () => {
    const root = mountFixture(`
      <div data-controller="modal" data-modal-url-value="/posts/new">
        <button type="button" data-action="click->modal#show">Open</button>
        <dialog data-modal-target="dialog">
          <turbo-frame id="new_post_modal" data-modal-target="frame"></turbo-frame>
        </dialog>
      </div>
    `)

    const dialog = root.querySelector("dialog")
    const frame = root.querySelector("turbo-frame")
    const showModalSpy = jest.spyOn(dialog, "showModal")

    root.querySelector("button").click()

    expect(showModalSpy).toHaveBeenCalled()
    expect(dialog.hasAttribute("open")).toBe(true)
    expect(frame.getAttribute("src")).toBe("/posts/new")
  })

  it("show does nothing when the dialog target is missing", () => {
    const root = mountFixture(`
      <div data-controller="modal" data-modal-url-value="/posts/new">
        <button type="button" data-action="click->modal#show">Open</button>
        <turbo-frame id="new_post_modal" data-modal-target="frame"></turbo-frame>
      </div>
    `)

    expect(() => root.querySelector("button").click()).not.toThrow()
  })

  it("close closes an open dialog and clears the turbo frame", () => {
    const root = mountFixture(`
      <div data-controller="modal" data-modal-url-value="/posts/new">
        <button type="button" id="open" data-action="click->modal#show">Open</button>
        <button type="button" id="shut" data-action="click->modal#close">Shut</button>
        <dialog data-modal-target="dialog">
          <turbo-frame id="new_post_modal" data-modal-target="frame"></turbo-frame>
        </dialog>
      </div>
    `)

    const dialog = root.querySelector("dialog")
    const frame = root.querySelector("turbo-frame")
    frame.innerHTML = "<p>loaded</p>"
    frame.setAttribute("src", "/posts/new")

    root.querySelector("#open").click()
    expect(dialog.hasAttribute("open")).toBe(true)

    const closeSpy = jest.spyOn(dialog, "close")
    root.querySelector("#shut").click()

    expect(closeSpy).toHaveBeenCalled()
    expect(frame.innerHTML).toBe("")
    expect(frame.hasAttribute("src")).toBe(false)
  })

  it("closeOnBackdrop closes only when the dialog itself is the event target", () => {
    const root = mountFixture(`
      <div data-controller="modal" data-modal-url-value="/x">
        <button type="button" data-action="click->modal#show">Open</button>
        <dialog data-modal-target="dialog" data-action="click->modal#closeOnBackdrop">
          <div id="inner">Panel</div>
        </dialog>
      </div>
    `)

    const dialog = root.querySelector("dialog")
    root.querySelector("button").click()
    expect(dialog.open).toBe(true)

    dialog.dispatchEvent(new MouseEvent("click", { bubbles: false }))
    expect(dialog.open).toBe(false)

    root.querySelector("button").click()
    expect(dialog.open).toBe(true)

    const inner = root.querySelector("#inner")
    inner.dispatchEvent(new MouseEvent("click", { bubbles: true }))
    expect(dialog.open).toBe(true)
  })

  it("afterSubmit closes the dialog when turbo:submit-end reports success", () => {
    const root = mountFixture(`
      <div data-controller="modal" data-modal-url-value="/posts/new">
        <button type="button" data-action="click->modal#show">Open</button>
        <dialog data-modal-target="dialog">
          <div data-action="turbo:submit-end->modal#afterSubmit">
            <turbo-frame id="new_post_modal" data-modal-target="frame"></turbo-frame>
          </div>
        </dialog>
      </div>
    `)

    const dialog = root.querySelector("dialog")
    const inner = root.querySelector("[data-action*='afterSubmit']")

    root.querySelector("button").click()
    expect(dialog.open).toBe(true)

    inner.dispatchEvent(new CustomEvent("turbo:submit-end", { bubbles: true, detail: { success: true } }))
    expect(dialog.open).toBe(false)
  })

  it("afterSubmit ignores failed submissions", () => {
    const root = mountFixture(`
      <div data-controller="modal" data-modal-url-value="/posts/new">
        <button type="button" data-action="click->modal#show">Open</button>
        <dialog data-modal-target="dialog">
          <div data-action="turbo:submit-end->modal#afterSubmit">
            <turbo-frame id="new_post_modal" data-modal-target="frame"></turbo-frame>
          </div>
        </dialog>
      </div>
    `)

    const dialog = root.querySelector("dialog")
    const inner = root.querySelector("[data-action*='afterSubmit']")

    root.querySelector("button").click()
    inner.dispatchEvent(new CustomEvent("turbo:submit-end", { bubbles: true, detail: { success: false } }))

    expect(dialog.open).toBe(true)
  })

  it("closes on turbo:before-cache (Turbo snapshot) via connect hook", () => {
    const root = mountFixture(`
      <div data-controller="modal" data-modal-url-value="/posts/new">
        <button type="button" data-action="click->modal#show">Open</button>
        <dialog data-modal-target="dialog">
          <turbo-frame id="new_post_modal" data-modal-target="frame"></turbo-frame>
        </dialog>
      </div>
    `)

    const dialog = root.querySelector("dialog")
    root.querySelector("button").click()
    expect(dialog.open).toBe(true)

    document.dispatchEvent(new Event("turbo:before-cache"))
    expect(dialog.open).toBe(false)
  })

  it("disconnect removes the turbo:before-cache listener", () => {
    const root = mountFixture(`
      <div data-controller="modal" data-modal-url-value="/posts/new">
        <button type="button" data-action="click->modal#show">Open</button>
        <dialog data-modal-target="dialog">
          <turbo-frame id="new_post_modal" data-modal-target="frame"></turbo-frame>
        </dialog>
      </div>
    `)

    const dialog = root.querySelector("dialog")
    root.querySelector("button").click()
    expect(dialog.open).toBe(true)

    application.stop()
    application = null
    document.dispatchEvent(new Event("turbo:before-cache"))
    expect(dialog.open).toBe(true)
  })
})
