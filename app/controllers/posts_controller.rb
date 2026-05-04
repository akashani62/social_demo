class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, only: %i[ new create edit update destroy ]
  before_action :require_post_author!, only: %i[ edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.includes(:user).order(created_at: :desc)
    @total_posts = @posts.size
    @posts_this_week = @posts.count { |post| post.created_at >= Time.current.beginning_of_week }
    @total_comments = Comment.count
    @top_author = User.joins(:posts).group("users.id").order(Arel.sql("COUNT(posts.id) DESC")).first
    @timeline_events = build_timeline_events
  end

  # GET /posts/1 or /posts/1.json
  def show
    @comments = @post.comments.includes(:user).order(created_at: :desc)

    respond_to do |format|
      format.html do
        if turbo_frame_request?
          if params[:preview] == "1"
            render partial: "posts/modal_preview", locals: { post: @post }
          else
            render partial: "posts/post_list_item", locals: { post: @post }
          end
        else
          render :show
        end
      end
    end
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)
    @post.user = current_user

    respond_to do |format|
      if @post.save
        format.turbo_stream if turbo_frame_request?
        format.html { redirect_to @post, notice: "Post was successfully created." } unless turbo_frame_request?
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.turbo_stream if turbo_frame_request?
        format.html { redirect_to @post, notice: "Post was successfully updated.", status: :see_other } unless turbo_frame_request?
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.turbo_stream if turbo_frame_request?
      format.html { redirect_to posts_path, notice: "Post was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :title, :body ])
    end

    def require_post_author!
      return if @post.user_id == current_user.id

      redirect_to @post, alert: "You can only edit your own posts."
    end

    def build_timeline_events
      post_events = Post.includes(:user).order(created_at: :desc).limit(4).map do |post|
        {
          kind: "post",
          actor: post.user&.name.presence || "User ##{post.user_id}",
          subject: post.title,
          at: post.created_at
        }
      end

      comment_events = Comment.includes(:user, :post).order(created_at: :desc).limit(4).map do |comment|
        {
          kind: "comment",
          actor: comment.user&.name.presence || "User ##{comment.user_id}",
          subject: comment.post&.title || "a post",
          at: comment.created_at
        }
      end

      (post_events + comment_events).sort_by { |event| -event[:at].to_i }.first(6)
    end
end
