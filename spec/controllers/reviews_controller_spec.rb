require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do

  fixtures :all

  describe "review" do
    it "create a review" do
      post :create, review: {vocabulary_id: 1}

      expect(Review.count).to eq 1
    end
  end

end
