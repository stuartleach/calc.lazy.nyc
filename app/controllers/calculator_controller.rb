class CalculatorController < ApplicationController
  before_action :initialize_session_variables, only: :index

  def index
    @display = "0"
    # @display = "0"
    # Initialize the start time for the session if it's not already set
    session[:start_time] ||= Time.current
    # refresh
    reset_session_variables
  end

  def calculate
    button = params[:button]

    # Start timing from when the button is clicked
    ActiveSupport::Notifications.instrument("calculate.action_controller") do
      case button
      when "C"
        reset_session_variables
      when "="
        perform_calculation
      else
        update_calculation(button)
      end
    end
end

    # Calculate elapsed time and store it
        session[:display] = @display

    respond_to do |format|
      format.turbo_stream
    end
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
    if valid_calculation?
      result = calculate_result
      update_session_and_display_for_result(result)
    else
      @display = "Error: Incomplete operation"
      reset_session_variables
    end
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

  def update_session_and_display_for_result(result)
    if result.is_a?(String)
      @display = result
      reset_session_variables
    else
      format_and_update_display(result)
      # Prepare for next operation
      session[:operation] = @display
      session[:operator] = nil
      session[:operand] = nil
    end
  end

  def format_and_update_display(result)
    # Remove trailing zeros from integer results
    @display = result % 1 == 0 ? result.to_i.to_s : result.to_s
  end

  def update_calculation(button)
    if ["+", "-", "*", "/"].include?(button)
      # Only set the operator if an operation has already been initiated
      session[:operator] = button if session[:operation] != "0" || !session[:operand].nil?
    elsif session[:operator].nil?
      session[:operation] = "0" if session[:operation].nil?
      # Append the button to session[:operation], handling leading zeros appropriately
      session[:operation] = if session[:operation] == "0" && button != "0"
                              button # Replace '0' with button if not intending to input '00', '000', etc.
                            else
                              session[:operation] + button
                            end
    # Initialize session[:operation] if it's nil
    else
      # Initialize session[:operand] as a string if it's nil, then append the button
      session[:operand] = (session[:operand] || "") + button
    end
    update_display
  end

  def update_display
    # This method updates the display based on the current calculation state.
    # It now immediately reflects the operator once it's selected.
    @display = if session[:operator].present? && (session[:operand].nil? || session[:operand].empty?)
                 # If an operator is selected but no operand yet, include the operator in the display.
                 "#{session[:operation]} #{session[:operator]}"
               elsif session[:operand].present?
                 # If there is an operand, show the full calculation.
                 "#{session[:operation]} #{session[:operator]} #{session[:operand]}"
               else
                 # Default to just showing the operation if no operator or operand is present.
                 session[:operation].to_s
               end
  end
end
