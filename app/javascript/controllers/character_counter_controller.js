import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="character-counter"
export default class extends Controller {
  static targets = ["input", "count"]

  connect() {
    this.updateCount()
  }

  updateCount() {
    const length = this.inputTarget.value.length
    this.countTarget.textContent = `${length} characters`
  }
}
