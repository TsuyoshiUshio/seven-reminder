class ReviewsController < ApplicationController

  # POST /reviews.json
  def create
    @review = Review.new(review_params)
    puts params.to_s
    vocabulary = Vocabulary.find(params[:review][:vocabulary_id])
    @review.vocabulary = vocabulary

      if @review.save
        render json: @review
      else
        render json: @review.errors, status: :unprocessable_entity
      end

  end

  private
  def review_params
    params.require(:review).permit(:vocabulary_id)
  end
end
