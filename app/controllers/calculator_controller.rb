class CalculatorController < ApplicationController
  before_action :initialize_session_variables, only: :index

  def index
    @display = session[:display] || "0"
    @elapsed = "0"
  end

  def calculate
    button = params[:button]

    start_time = Time.current

    case button
    when "C"
      reset_session_variables
    when "="
      perform_calculation
    else
      update_calculation(button)
    end

    @elapsed = (Time.current - start_time).round(2)

    respond_to do |format|
      format.turbo_stream
      format.json { render json: @result }
      format.any { render plain: "Not Acceptable", status: :not_acceptable }
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
    session[:display] = "0"
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
      session[:operation] = result.to_s
      session[:operator] = nil
      session[:operand] = nil
      @display = result % 1 == 0 ? result.to_i.to_s : result.to_s
    end
  end

  def update_calculation(button)
    if ["+", "-", "*", "/"].include?(button)
      session[:operator] = button if session[:operation] != "0" || !session[:operand].nil?
    elsif session[:operator].nil?
      session[:operation] = "0" if session[:operation].nil?
      session[:operation] = if session[:operation] == "0" && button != "0"
                              button
                            else
                              session[:operation] + button
                            end
    else
      session[:operand] = (session[:operand] || "") + button
    end
    update_display
  end

  def update_display
    @display = if session[:operator].present? && (session[:operand].nil? || session[:operand].empty?)
                 "#{session[:operation]} #{session[:operator]}"
               elsif session[:operand].present?
                 "#{session[:operation]} #{session[:operator]} #{session[:operand]}"
               else
                 session[:operation].to_s
               end
    session[:display] = @display
  end
end
