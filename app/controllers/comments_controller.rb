class CommentsController < ApplicationController
  before_action :authenticate_user!, except: %i[ index show ]
  before_action :set_comment, only: %i[ show destroy ]

  # GET /comments
  def index
    @comments = Comment.all
  end

  # GET /comments/1
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # POST /comments
  def create
    @comment = current_user.comments.build(comment_params)

    if @comment.save
      redirect_to post_path(@comment.post), notice: "Comment was successfully created."
    else
      redirect_to post_path(comment_params[:post_id]), alert: "Comment could not be created."
    end
  end

  # DELETE /comments/1
  # Only comment owner OR post author can delete
  def destroy
    if @comment.user == current_user || @comment.post.user == current_user
      post = @comment.post
      @comment.destroy!
      redirect_to post_path(post), notice: "Comment was successfully destroyed.", status: :see_other
    else
      redirect_to post_path(@comment.post), alert: "You can only delete your own comments."
    end
  end

  private

  def set_comment
    @comment = Comment.find(params.expect(:id))
  end

  def comment_params
    params.expect(comment: [ :body, :post_id ])
  end
end
