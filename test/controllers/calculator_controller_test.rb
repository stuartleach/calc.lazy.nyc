require "test_helper"
# require "rails_helper"

class CalculatorControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get calculator_index_url
    assert_response :success
  end
end

# RSpec.describe CalculatorController, type: :controller do
#   describe "GET #index" do
#     it "responds successfully" do
#       get :index
#       expect(response).to be_successful
#     end

#     it "initializes session variables" do
#       get :index
#       expect(session[:operation]).to eq("0")
#       expect(session[:operator]).to be_nil
#       expect(session[:operand]).to be_nil
#       expect(session[:display]).to eq("0")
#     end
#   end

#   describe "POST #calculate" do
#     it 'performs calculation when "=" is clicked and valid calculation' do
#       session[:operation] = "5"
#       session[:operator] = "+"
#       session[:operand] = "3"
#       post :calculate, params: { button: "=" }
#       expect(session[:display]).to eq("8")
#     end

#     it "updates operation when number is clicked" do
#       post :calculate, params: { button: "5" }
#       expect(session[:operation]).to eq("5")
#     end

#     it "updates operator when operator is clicked" do
#       post :calculate, params: { button: "+" }
#       expect(session[:operator]).to eq("+")
#     end

#     it 'resets session variables when "C" is clicked' do
#       post :calculate, params: { button: "C" }
#       expect(session[:operation]).to eq("0")
#       expect(session[:operator]).to be_nil
#       expect(session[:operand]).to be_nil
#       expect(session[:display]).to eq("0")
#     end
#   end
# end
