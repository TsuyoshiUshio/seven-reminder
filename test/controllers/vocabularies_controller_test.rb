require 'test_helper'

class VocabulariesControllerTest < ActionController::TestCase
  setup do
    @vocabulary = vocabularies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vocabularies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vocabulary" do
    assert_difference('Vocabulary.count') do
      post :create, vocabulary: { confirmed: @vocabulary.confirmed, definition: @vocabulary.definition, example: @vocabulary.example, name: @vocabulary.name, url: @vocabulary.url }
    end

    assert_redirected_to vocabulary_path(assigns(:vocabulary))
  end

  test "should show vocabulary" do
    get :show, id: @vocabulary
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @vocabulary
    assert_response :success
  end

  test "should update vocabulary" do
    patch :update, id: @vocabulary, vocabulary: { confirmed: @vocabulary.confirmed, definition: @vocabulary.definition, example: @vocabulary.example, name: @vocabulary.name, url: @vocabulary.url }
    assert_redirected_to vocabulary_path(assigns(:vocabulary))
  end

  test "should destroy vocabulary" do
    assert_difference('Vocabulary.count', -1) do
      delete :destroy, id: @vocabulary
    end

    assert_redirected_to vocabularies_path
  end
end
