module AppointmentsHelper
  HOUR_PX           = 64
  CALENDAR_START_H  = 7

  def appointment_top_px(appt)
    t = appt.scheduled_at.in_time_zone
    ((t.hour - CALENDAR_START_H) * HOUR_PX) + (t.min.to_f * HOUR_PX / 60).round
  end

  def appointment_height_px(appt)
    [ (appt.duration_minutes.to_f * HOUR_PX / 60).round, 24 ].max
  end

  STATUS_COLORS = {
    "scheduled"                => "bg-blue-100 border-blue-300 text-blue-900",
    "attended"                 => "bg-green-100 border-green-300 text-green-900",
    "absent_notified"          => "bg-amber-100 border-amber-300 text-amber-900",
    "absent_late"              => "bg-red-100 border-red-300 text-red-900",
    "rescheduled"              => "bg-purple-100 border-purple-300 text-purple-900",
    "cancelled_by_professional"=> "bg-gray-100 border-gray-300 text-gray-500"
  }.freeze

  def appointment_color_classes(appt)
    STATUS_COLORS[appt.status] || STATUS_COLORS["scheduled"]
  end
end
