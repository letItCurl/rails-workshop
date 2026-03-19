class PostsController < ApplicationController
  before_action :authenticate_user!, except: %i[ index show ]
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :authorize_owner!, only: %i[ edit update destroy ]

  # GET /posts
  def index
    @posts = Post.all
  end

  # GET /posts/1
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to @post, notice: "Post was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /posts/1
  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy!
    redirect_to posts_path, notice: "Post was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params.expect(:id))
    end

    def authorize_owner!
      unless @post.user == current_user
        redirect_to posts_path, alert: "You can only edit/delete your own posts."
      end
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body, :published, :cover_image, tag_ids: [])
    end
end
