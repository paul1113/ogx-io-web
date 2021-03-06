class Admin::CommentsController < ApplicationController

  before_action :set_comment, only: [:destroy, :delete_all, :resume]

  layout 'admin'

  respond_to :html

  def index
    authorize current_user, :manage?
    @all_comments = Comment.where(commentable_type: "Post")

    if !current_user.admin?
      @all_comments = @all_comments.in(board_id: current_user.managing_board_ids)
    end

    if !params[:board_id].blank?
      @all_comments = @all_comments.where(board_id: params[:board_id].to_i)
    end

    if !params[:status].blank?
      case params[:status].to_i
        when 1
          @all_comments = @all_comments.normal
        when 2
          @all_comments = @all_comments.deleted
      end
    end

    @comments = @all_comments.desc(:_id).page(params[:page]).per(50)
    respond_with(@comments)
  end

  def resume
    authorize @comment
    @comment.resume_by(current_user)
    respond_to do |format|
      format.js { render 'refresh' }
    end
  end

  def destroy
    authorize @comment
    @comment.delete_by(current_user)
    respond_to do |format|
      format.js { render 'refresh' }
    end
  end

  def delete_all
    authorize @comment
    @comment.delete_all_by(current_user)
    respond_to do |format|
      format.js { render js: "location.reload();" }
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end
end
