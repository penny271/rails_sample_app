class Physician < ApplicationRecord
  has_many :appointments, class_name: "Appointment", foreign_key: "physician_id"
  has_many :patients, through: :appointments
end