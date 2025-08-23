class WorkLog < ApplicationRecord
  belongs_to :employee, class_name: 'User'
  
  validates :clock_in, presence: true
  validates :employee_id, presence: true
  validate :clock_out_after_clock_in, if: :clock_out?
  validate :employee_must_be_staff
  
  scope :pending_approval, -> { where(approved: false) }
  scope :approved, -> { where(approved: true) }
  scope :for_date, ->(date) { where(clock_in: date.beginning_of_day..date.end_of_day) }
  scope :for_employee, ->(employee) { where(employee: employee) }
  
  def hours_worked
    return 0 unless clock_in && clock_out
    ((clock_out - clock_in) / 1.hour).round(2)
  end
  
  def currently_working?
    clock_in && !clock_out
  end
  
  def approve!
    update!(approved: true)
  end
  
  def reject!
    # For now, we'll just delete rejected logs
    # In a real app, you might want to keep them with a rejected status
    destroy
  end
  
  def formatted_hours
    \"#{hours_worked} hours\"
  end
  
  def work_date
    clock_in.to_date
  end
  
  private
  
  def clock_out_after_clock_in
    return unless clock_in && clock_out
    errors.add(:clock_out, 'must be after clock in time') if clock_out <= clock_in
  end
  
  def employee_must_be_staff
    return unless employee
    errors.add(:employee, 'must be a staff member') unless employee.employee?
  end
end