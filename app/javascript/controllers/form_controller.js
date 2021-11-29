import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  static targets = [ "timezone" ]

  connect() {
    const config = {
      enableTime: true,
      altInput: true,
      altFormat: "F j, Y h:i K",
      dateFormat: "Y-m-d H:i",
    }
    flatpickr(".datetime", config)

    if (this.hasTimezoneTarget) {
      this.timezoneTarget.value = Intl.DateTimeFormat().resolvedOptions().timeZone
    }
  }
}
