require 'rails_helper'

RSpec.describe VocabulariesController do

  fixtures :all

  describe "remind" do
    it "get all @vocabularies" do
      get :remind
      expect(assigns(:vocabularies).size).to eq 2
    end
  end

end