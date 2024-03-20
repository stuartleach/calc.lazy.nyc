class CalculatorController < ApplicationController
  before_action :initialize_session_variables, only: :index

  def index
    @display = "0"
    session[:start_time] ||= Time.current
    reset_session_variables
  end

  def calculate
    button = params[:button]

    if button == "C"
      reset_session_variables
    elsif button == "="
      perform_calculation
    elsif ["+", "-", "*", "/"].include?(button)
      perform_calculation if valid_calculation?
      session[:operator] = button
      session[:operand] = nil # Clear operand for the next operation
    else
      update_calculation(button)
    end

    session[:display] = @display
    respond_to(&:turbo_stream)
  end

  private

  def initialize_session_variables
    session[:operation] ||= "0"
    session[:operator] ||= nil
    session[:operand] ||= nil
    session[:display] ||= "0"
  end

  def reset_session_variables
    session[:operation] = "0"
    session[:operator] = nil
    session[:operand] = nil
    @display = "0"
  end

  def perform_calculation
    return unless valid_calculation?

    result = calculate_result
    # Update display and prepare for next operation
    @display = format_result(result)
    session[:operation] = @display
    # Reset for next operation
    session[:operator] = nil
    session[:operand] = nil
  end

  def valid_calculation?
    session[:operation].present? && session[:operator].present? && session[:operand].present?
  end

  def calculate_result
    operation = session[:operation].to_f
    operand = session[:operand].to_f
    case session[:operator]
    when "+"
      operation + operand
    when "-"
      operation - operand
    when "*"
      operation * operand
    when "/"
      operand.zero? ? "Error: Division by 0" : operation / operand
    else
      "Error: Invalid operator"
    end
  end

  def update_calculation(button)
    if session[:operator]
      # If an operator is already set, we're working on the operand
      session[:operand] = (session[:operand] || "") + button
    else
      # Append button to operation or replace it if it's the initial zero
      session[:operation] = (session[:operation] == "0" ? "" : session[:operation]) + button
    end
    update_display
  end

  def update_display
    @display = if session[:operand].nil?
                 "#{session[:operation]} #{session[:operator]}"
               else
                 "#{session[:operation]} #{session[:operator]} #{session[:operand]}"
               end
  end

  def format_result(result)
    # Format the result to remove trailing zeros if it's an integer
    result % 1 == 0 ? result.to_i.to_s : result.to_s
  end
end
