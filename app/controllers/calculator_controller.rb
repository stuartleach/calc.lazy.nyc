# app/controllers/calculator_controller.rb
class CalculatorController < ApplicationController

  def index
    # This action might set up instance variables for the view,
    # but typically won't contain 'puts' statements.
  end

  def calculate
    button = params[:button]

    # Reset the calculator
    if button == 'C'
      reset_session_variables
      @display = ''
    elsif button == '='
      # Perform calculation
      perform_calculation
    else
      # Update operation, operator, or operand
      update_calculation(button)
    end

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def reset_session_variables
    session[:operation] = nil
    session[:operator] = nil
    session[:operand] = nil
  end

  def perform_calculation
    if session[:operation].present? && session[:operator].present? && session[:operand].present?
      begin
        # Perform calculation with floating-point precision
        operation = session[:operation].to_f
        operand = session[:operand].to_f
        result = case session[:operator]
                 when '+'
                   operation + operand
                 when '-'
                   operation - operand
                 when '*'
                   operation * operand
                 when '/'
                   # Check for division by zero
                   if operand.zero?
                     @display = 'Error: Division by 0'
                     reset_session_variables
                     return # Exit the method early
                   else
                     operation / operand
                   end
                 else
                   'Error: Invalid operator'
                 end
  
        # Check for division by zero error or invalid operator before setting @result
        unless result.is_a?(String)
          # Format result to remove trailing .0 if applicable
          @result = result % 1 == 0 ? result.to_i : result
          session[:operation] = @result.to_s
          @display = @result.to_s
          session[:operator] = nil
          session[:operand] = nil
        else
          @display = result
        end
      rescue StandardError => e
        @display = "Error: #{e.message}"
        reset_session_variables
      end
    else
      @display = 'Error: Incomplete operation'
    end
  end
  
  

  def update_calculation(button)
    if ['+', '-', '*', '/'].include?(button)
      session[:operator] = button unless session[:operation].nil? # Ensure there's an operation to operate on
      @display = "#{session[:operation]} #{session[:operator]}"
    else
      if session[:operator].nil?
        session[:operation] = (session[:operation] || '') + button
        @display = session[:operation]
      else
        session[:operand] = (session[:operand] || '') + button
        @display = "#{session[:operation]} #{session[:operator]} #{session[:operand]}"
      end
    end
  end
end
