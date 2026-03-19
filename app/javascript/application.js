// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import "trix"
import "@rails/actiontext"

// Override native browser confirm with custom modal
import ConfirmController from "controllers/confirm_controller"

Turbo.config.forms.confirm = (message, element) => {
  return ConfirmController.show(message)
}
