class Patient < ApplicationRecord
  has_many :appointments, class_name="Appointment", foreign_key="patient_id", dependent: :destroy

  has_many :physicians, class_name="Physicians", foreign_key="physician_id", source: 'physician', through: "appointments"
end