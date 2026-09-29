import { Controller } from "@hotwired/stimulus"

const HOUR_PX         = 64
const CALENDAR_START  = 7

export default class extends Controller {
  clickSlot(event) {
    // Ignore clicks on appointment links
    if (event.target.closest("a")) return

    const col      = event.currentTarget
    const date     = col.dataset.calendarDateValue
    const rect     = col.getBoundingClientRect()
    const relY     = event.clientY - rect.top
    const totalMin = CALENDAR_START * 60 + Math.floor(relY * 60 / HOUR_PX)
    const hour     = Math.floor(totalMin / 60)
    const minute   = Math.floor((totalMin % 60) / 15) * 15 // snap to 15 min
    const at       = `${date}T${String(hour).padStart(2, "0")}:${String(minute).padStart(2, "0")}`

    window.location.href = `/appointments/new?at=${encodeURIComponent(at)}`
  }
}
