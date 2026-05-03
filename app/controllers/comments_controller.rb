class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, only: %i[ new create edit update destroy ]
  before_action :require_comment_author!, only: %i[ edit update destroy ]

  # GET /comments or /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1 or /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new(prefilled_comment_attrs)
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments or /comments.json
  def create
    @comment = Comment.new(create_comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @comment.post, notice: "Comment was successfully created.", status: :see_other }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1 or /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(update_comment_params)
        format.html { redirect_to @comment.post, notice: "Comment was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    post = @comment.post
    @comment.destroy!

    respond_to do |format|
      format.html { redirect_to post, notice: "Comment was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def create_comment_params
      params.expect(comment: [ :post_id, :body ])
    end

    def update_comment_params
      params.expect(comment: [ :body ])
    end

    def prefilled_comment_attrs
      return {} unless params[:comment].is_a?(ActionController::Parameters)
      params[:comment].permit(:post_id).to_h.compact_blank
    end

    def require_comment_author!
      return if @comment.user_id == current_user.id

      redirect_to @comment.post, alert: "You can only edit your own comments."
    end
end
