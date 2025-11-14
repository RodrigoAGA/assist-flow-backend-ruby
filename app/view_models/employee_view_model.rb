# ViewModel for Employee presentation logic
# Handles data transformation and business logic for employee views

class EmployeeViewModel
  attr_reader :employee
  
  def initialize(employee)
    @employee = employee
  end
  
  # Generate new credentials
  def generate_credentials
    {
      pin: Employee.generate_pin,
      password: Employee.generate_password
    }
  end
  
  # Create employee with auto-generated credentials
  def self.create_with_credentials(params)
    credentials = {
      pin: Employee.generate_pin,
      password: Employee.generate_password
    }
    
    employee = Employee.new(params)
    employee.pin = credentials[:pin]
    employee.password = credentials[:password]
    
    if employee.save
      {
        success: true,
        employee: employee,
        credentials: credentials
      }
    else
      {
        success: false,
        errors: employee.errors.full_messages
      }
    end
  end
  
  # Reset employee credentials
  def reset_credentials(reset_pin: false, reset_password: false)
    new_credentials = {}
    
    if reset_pin
      new_pin = Employee.generate_pin
      employee.pin = new_pin
      new_credentials[:pin] = new_pin
    end
    
    if reset_password
      new_password = Employee.generate_password
      employee.password = new_password
      new_credentials[:password] = new_password
    end
    
    if employee.save
      {
        success: true,
        credentials: new_credentials
      }
    else
      {
        success: false,
        errors: employee.errors.full_messages
      }
    end
  end
  
  # Employee summary for listing
  def summary
    {
      id: employee.id,
      name: employee.name,
      dni: employee.dni,
      email: employee.email,
      phone: employee.phone,
      job_position: employee.job_position,
      salary: employee.salary,
      is_active: employee.is_active,
      company_id: employee.company_id
    }
  end
  
  # Detailed employee view
  def detailed
    summary.merge(
      company_name: employee.company.name,
      created_at: employee.created_at,
      updated_at: employee.updated_at
    )
  end
end
