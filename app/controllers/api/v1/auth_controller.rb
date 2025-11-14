# Authentication Controller
module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_request, only: [:register, :admin_login, :employee_login, :companies]
      
      # POST /api/v1/auth/register
      def register
        company = Company.new(company_params)
        profile = Profile.new(profile_params.merge(company: company))
        
        if company.save && profile.save
          token = JsonWebToken.encode({ id: profile.id, type: 'admin' })
          
          render_success({
            message: 'Administrador y empresa creados exitosamente',
            token: token,
            user: {
              id: profile.id,
              name: profile.full_name,
              email: profile.email,
              company_id: company.id,
              company_name: company.name
            }
          }, :created)
        else
          render_bad_request(profile.errors.full_messages + company.errors.full_messages)
        end
      end
      
      # POST /api/v1/auth/admin/login
      def admin_login
        profile = Profile.find_by(email: params[:email])
        
        if profile&.authenticate(params[:password])
          token = JsonWebToken.encode({ id: profile.id, type: 'admin' })
          
          render_success({
            message: 'Login exitoso',
            token: token,
            user: {
              id: profile.id,
              name: profile.full_name,
              email: profile.email,
              company_id: profile.company_id,
              company_name: profile.company&.name
            }
          })
        else
          render_unauthorized('Credenciales inválidas')
        end
      end
      
      # POST /api/v1/auth/employee/login
      def employee_login
        employees = Employee.where(company_id: params[:company_id], is_active: true)
        
        employee = employees.find do |emp|
          emp.verify_pin(params[:pin])
        end
        
        if employee&.authenticate(params[:password])
          token = JsonWebToken.encode({ id: employee.id, type: 'employee' })
          
          render_success({
            message: 'Login exitoso',
            token: token,
            employee: {
              id: employee.id,
              name: employee.name,
              dni: employee.dni,
              job_position: employee.job_position,
              company_id: employee.company_id
            }
          })
        else
          render_unauthorized('Credenciales inválidas')
        end
      end
      
      # GET /api/v1/auth/me
      def me
        if current_user_type == 'admin'
          render_success({
            type: 'admin',
            user: {
              id: current_user.id,
              name: current_user.full_name,
              email: current_user.email,
              company_id: current_user.company_id,
              company_name: current_user.company&.name
            }
          })
        elsif current_user_type == 'employee'
          render_success({
            type: 'employee',
            user: {
              id: current_user.id,
              name: current_user.name,
              dni: current_user.dni,
              job_position: current_user.job_position,
              company_id: current_user.company_id,
              company_name: current_user.company.name
            }
          })
        end
      end
      
      # GET /api/v1/auth/companies
      def companies
        companies = Company.select(:id, :name)
        render_success(companies)
      end
      
      private
      
      def profile_params
        params.require(:profile).permit(:full_name, :email, :password)
      end
      
      def company_params
        params.require(:company).permit(
          :name, :work_start_time, :work_end_time, :late_threshold_minutes
        )
      end
    end
  end
end
