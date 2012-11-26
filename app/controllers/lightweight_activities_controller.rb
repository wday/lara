require_dependency "application_controller"

class LightweightActivitiesController < ApplicationController
  before_filter :set_activity, :except => [:index, :new, :create]

  def index
    if current_user.blank?
      @activities ||= LightweightActivity.find(:all)
    else
      @activities = LightweightActivity.find_all_by_user_id(current_user.id)
    end
  end

  def show
    redirect_to activity_page_path(@activity, @activity.pages.first)
  end

  def new
    @activity = LightweightActivity.new()
  end

  def create
    @activity = LightweightActivity.create(params[:lightweight_activity])
    if current_user
      @activity.user = current_user
    end
    if @activity.save
      flash[:notice] = "Lightweight Activity #{@activity.name} was created."
      redirect_to edit_activity_path(@activity)
    else
      flash[:warning] = "There was a problem creating the new Lightweight Activity."
      render :new
    end
  end

  def edit
  end

  def update
    if @activity.update_attributes(params[:lightweight_activity])
      if request.xhr?
        render :text => params[:lightweight_activity].values.first
      else
        flash[:notice] = "Activity #{@activity.name} was updated."
        redirect_to edit_activity_path(@activity)
      end
    else
      if request.xhr?
        render :text => "There was a problem updating activity #{@activity.name}. Please reload the page and try again."
      else
        flash[:warning] = "There was a problem updating activity #{@activity.name}."
        redirect_to edit_activity_path(@activity)
      end
    end
  end

  def destroy
    if @activity.delete
      flash[:notice] = "Activity #{@activity.name} was deleted."
      redirect_to activities_path
    else
      flash[:warning] = "There was a problem deleting activity #{@activity.name}."
      redirect_to edit_activity_path(@activity)
    end
  end

  def move_up
    @page = @activity.pages.find(params[:id])
    @page.move_higher
    redirect_to :back
  end

  def move_down
    @page = @activity.pages.find(params[:id])
    @page.move_lower
    redirect_to :back
  end

  def reorder_pages
  end

  private
  def set_activity
    if params[:activity_id]
      @activity = LightweightActivity.find(params[:activity_id])
    else
      @activity = LightweightActivity.find(params[:id])
    end
  end
end
