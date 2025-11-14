# Employees Controller using EmployeeViewModel
module Api
  module V1
    class EmployeesController < BaseController
      before_action :require_admin, except: [:show]
      before_action :set_employee, only: [:show, :update, :destroy, :reset_credentials]
      
      # GET /api/v1/employees
      def index
        employees = Employee.by_company(current_user.company_id)
        
        employees = employees.where(is_active: params[:is_active]) if params[:is_active].present?
        employees = employees.search(params[:search]) if params[:search].present?
        
        employees = employees.order(name: :asc)
        
        view_models = employees.map { |emp| EmployeeViewModel.new(emp).summary }
        render_success(view_models)
      end
      
      # GET /api/v1/employees/:id
      def show
        # Check permissions
        if current_user_type == 'admin' && @employee.company_id != current_user.company_id
          return render_forbidden
        end
        
        if current_user_type == 'employee' && @employee.id != current_user.id
          return render_forbidden
        end
        
        view_model = EmployeeViewModel.new(@employee)
        render_success(view_model.detailed)
      end
      
      # POST /api/v1/employees
      def create
        params_with_company = employee_params.merge(
          company_id: current_user.company_id
        )
        
        result = EmployeeViewModel.create_with_credentials(params_with_company)
        
        if result[:success]
          render_success({
            message: 'Empleado creado exitosamente',
            employee: EmployeeViewModel.new(result[:employee]).summary,
            credentials: result[:credentials]
          }, :created)
        else
          render_bad_request(result[:errors])
        end
      end
      
      # PATCH /api/v1/employees/:id
      def update
        if @employee.company_id != current_user.company_id
          return render_forbidden
        end
        
        if @employee.update(employee_update_params)
          view_model = EmployeeViewModel.new(@employee)
          render_success({
            message: 'Empleado actualizado exitosamente',
            employee: view_model.summary
          })
        else
          render_bad_request(@employee.errors.full_messages)
        end
      end
      
      # DELETE /api/v1/employees/:id
      def destroy
        if @employee.company_id != current_user.company_id
          return render_forbidden
        end
        
        @employee.update(is_active: false)
        render_success({ message: 'Empleado desactivado exitosamente' })
      end
      
      # POST /api/v1/employees/:id/reset_credentials
      def reset_credentials
        if @employee.company_id != current_user.company_id
          return render_forbidden
        end
        
        view_model = EmployeeViewModel.new(@employee)
        result = view_model.reset_credentials(
          reset_pin: params[:reset_pin],
          reset_password: params[:reset_password]
        )
        
        if result[:success]
          render_success({
            message: 'Credenciales reseteadas exitosamente',
            employee: {
              id: @employee.id,
              name: @employee.name,
              dni: @employee.dni
            },
            new_credentials: result[:credentials]
          })
        else
          render_bad_request(result[:errors])
        end
      end
      
      private
      
      def set_employee
        @employee = Employee.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_not_found
      end
      
      def employee_params
        params.permit(
          :name, :dni, :email, :phone, :job_position, :salary
        )
      end
      
      def employee_update_params
        params.permit(
          :name, :dni, :email, :phone, :job_position, :salary, :is_active
        )
      end
    end
  end
end
