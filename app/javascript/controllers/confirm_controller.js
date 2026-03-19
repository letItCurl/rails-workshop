import { Controller } from "@hotwired/stimulus"

// This controller is not connected via data-controller.
// It provides a static method used by the Turbo confirm override.
export default class extends Controller {
  static show(message) {
    return new Promise((resolve) => {
      const backdrop = document.createElement("div")
      backdrop.className = "fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
      backdrop.setAttribute("data-confirm-backdrop", "")

      backdrop.innerHTML = `
        <div class="bg-white rounded-lg shadow-xl w-full max-w-sm mx-auto" role="dialog" aria-modal="true" aria-labelledby="confirm-title">
          <div class="p-6">
            <div class="flex items-center gap-3 mb-4">
              <div class="flex-shrink-0 w-10 h-10 rounded-full bg-red-50 flex items-center justify-center">
                <svg class="w-5 h-5 text-red-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
              </div>
              <h2 id="confirm-title" class="text-lg font-semibold text-black">${message}</h2>
            </div>
            <p class="text-sm text-gray-600 mb-6">This action cannot be undone.</p>
            <div class="flex flex-col-reverse sm:flex-row gap-3 sm:justify-end">
              <button data-action="cancel" class="w-full sm:w-auto text-center border border-gray-200 rounded-lg px-4 py-2 text-sm font-medium hover:bg-gray-50 transition-colors cursor-pointer">
                Cancel
              </button>
              <button data-action="confirm" class="w-full sm:w-auto text-center bg-red-600 text-white rounded-lg px-4 py-2 text-sm font-medium hover:bg-red-700 transition-colors cursor-pointer">
                Delete
              </button>
            </div>
          </div>
        </div>
      `

      const close = (result) => {
        backdrop.remove()
        document.removeEventListener("keydown", onKeydown)
        resolve(result)
      }

      const onKeydown = (e) => {
        if (e.key === "Escape") close(false)
      }

      backdrop.querySelector('[data-action="cancel"]').addEventListener("click", () => close(false))
      backdrop.querySelector('[data-action="confirm"]').addEventListener("click", () => close(true))
      backdrop.addEventListener("click", (e) => {
        if (e.target === backdrop) close(false)
      })
      document.addEventListener("keydown", onKeydown)

      document.body.appendChild(backdrop)
      backdrop.querySelector('[data-action="cancel"]').focus()
    })
  }
}
