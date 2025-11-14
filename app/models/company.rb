# == Schema Information
#
# Table name: companies
#
#  id                     :uuid             not null, primary key
#  name                   :string           not null
#  work_start_time        :time             default("08:00:00")
#  work_end_time          :time             default("17:00:00")
#  late_threshold_minutes :integer          default(15)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Company < ApplicationRecord
  # Relationships
  has_many :employees, dependent: :destroy
  has_many :company_locations, dependent: :destroy
  has_many :vacation_requests, dependent: :destroy
  has_many :profiles, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :payroll_calculations, dependent: :destroy
  
  # Validations
  validates :name, presence: true, uniqueness: true
  
  # Instance methods
  def within_work_hours?(time = Time.current)
    return true unless work_start_time && work_end_time
    
    current_time = time.strftime('%H:%M:%S')
    current_time >= work_start_time.strftime('%H:%M:%S') && 
    current_time <= work_end_time.strftime('%H:%M:%S')
  end
  
  def is_late?(time)
    return false unless work_start_time
    
    time.strftime('%H:%M:%S') > work_start_time.strftime('%H:%M:%S')
  end
  
  def calculate_late_minutes(time)
    return 0 unless work_start_time && is_late?(time)
    
    expected = Time.parse(work_start_time.strftime('%H:%M:%S'))
    actual = Time.parse(time.strftime('%H:%M:%S'))
    ((actual - expected) / 60).to_i
  end
end
