import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["crpField"]

  connect() {
    this.toggleCrp()
  }

  toggleCrp() {
    const select = this.element.querySelector("select[name*='kind']")
    this.crpFieldTarget.classList.toggle("hidden", select.value !== "psychologist")
  }
}
