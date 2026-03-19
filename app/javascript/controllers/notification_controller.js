import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 3000)
  }

  dismiss() {
    this.element.remove()
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }
}
