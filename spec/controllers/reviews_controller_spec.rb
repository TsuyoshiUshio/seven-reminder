require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do

  fixtures :all

  let :user do
    User.create!(email: "me@home.com", password: "greatPassw0rd")
  end
  before {sign_in user}

  describe "review" do
    it "create a review" do
      post :create, review: {vocabulary_id: 1}

      expect(Review.count).to eq 1
    end
  end

end
