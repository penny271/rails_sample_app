class Appointment < ApplicationRecord
  belongs_to :physician, class_name: "Physician", foreign_key: "physician_id"
  belongs_to :patient, class_name: "Patient", foreign_key: "patient_id"
end

class Patient < ApplicationRecord
  has_many :appointments, class_name="Appointment", foreign_key="patient_id", dependent: :destroy

  has_many :physicians, class_name="Physician", foreign_key="physician_id", through: "appointments", source: 'physician'
end

class Physician < ApplicationRecord
  has_many :appointments, class_name: "Appointment", foreign_key: "physician_id"
  has_many :patients, through: :appointments, source: "patient"
end