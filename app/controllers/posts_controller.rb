class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :toggle, :resume]
  before_action :set_board, only: [:index, :new, :create, :elites, :deleted]

  # GET /posts
  # GET /posts.json
  def index
    @all_posts = @board.posts.normal
    @posts = @all_posts.desc(:created_at).page(params[:page]).per(10)
  end

  def elites
    @all_posts = @board.posts.normal.elites
    @posts = @all_posts.desc(:created_at).page(params[:page]).per(10)
  end

  def deleted
    authorize @board, :blocked_users?
    @all_posts = @board.posts.deleted
    @posts = @all_posts.desc(:updated_at).page(params[:page]).per(10)
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @board = @post.board
  end

  # GET /posts/new
  def new
    @post = Post.new
    @post.board = @board
    authorize @post
    @parent = Post.find(params[:parent]) if params[:parent]
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)
    @post.board = @board
    authorize @post
    @post.author = current_user

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post}
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    authorize @post
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle
    authorize @post
    p = Hash.new
    pp = post_params
    pp.each do |k, v|
      pp[k] = p[k] = 1 - @post.send(k)
    end
    respond_to do |format|
      if @post.update(pp)
        format.json { render json: p, status: :ok, location: @post }
      else
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def resume
    authorize @post
    @post.update(deleted: 0)
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    authorize @post
    @post.delete_myself
    respond_to do |format|
      # format.html { redirect_to board_posts_path(@post.board), notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    def set_board
      @board = Board.find(params[:board_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params[:post].permit(:title, :body, :parent, :topic_id, :elite)
    end
end
