require 'rails_helper'

RSpec.describe VocabulariesController do

  fixtures :all

  let :user do
    User.create!(email: "me@home.com", password: "greatPassw0rd")
  end
  before {sign_in user}

  describe "remind" do
    it "get all @vocabularies" do
      get :remind
      expect(assigns(:vocabularies).size).to eq 2
    end
  end

  describe "adding user_id for vocabulary" do
    it "is added when you entry the vocabulary" do
      SOME_USER_ID = 8
      expect {
        post :create, :vocabulary => {:id => 1, :name => "cat", :definition => "an animal", :confirmed => true, :user_id => SOME_USER_ID}
      }.to change(Vocabulary, :count).by(1)
      expect(Vocabulary.where(user_id: SOME_USER_ID).count).to eq(1)
    end
  end

end