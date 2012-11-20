require_dependency "application_controller"

class InteractivePagesController < ApplicationController
  before_filter :set_page, :except => [:new, :create]

  def show
    @all_pages = @activity.pages
    current_idx = @all_pages.index(@page)
    @previous_page = (current_idx > 0) ? @all_pages[current_idx-1] : nil
    @next_page = (current_idx < (@all_pages.size-1)) ? @all_pages[current_idx+1] : nil

    respond_to do |format|
      format.html
      format.xml
      # format.run_html { render :show }
    end
  end

  def new
    # There's really nothing to do here; we can go through #create and skip on ahead to #edit.
    create
  end

  def create
    @activity = LightweightActivity.find(params[:activity_id])
    @page = InteractivePage.create!(:lightweight_activity => @activity)
    flash[:notice] = "A new page was added to #{@activity.name}"
    redirect_to edit_activity_page_path(@activity, @page)
  end

  def edit
  end

  def update
    respond_to do |format|
      if @page.update_attributes(params[:interactive_page])
        format.html do
          if request.xhr?
            # *** repond with the new value ***
            render :text => params[:interactive_page].values.first
          else
            flash[:notice] = "Page #{@page.name} was updated."
            redirect_to edit_activity_page_path(@activity, @page)
          end
        end
      else
        format.html do
          if request.xhr?
            # *** repond with the old value ***
            render :text => @page[params[:interactive_page].keys.first]
          else
            flash[warning] = "There was a problem updating Page #{@page.name}."
            redirect_to edit_activity_page_path(@activity, @page)
          end
        end
      end
    end
  end

  def destroy
    if @page.delete
      flash[:notice] = "Page #{@page.name} was deleted."
      redirect_to edit_activity_path(@activity)
    else
      flash[:warning] = "There was a problem deleting page #{@page.name}."
      redirect_to edit_activity_path(@activity)
    end
  end

  def add_embeddable
    e = params[:embeddable_type].constantize.create!
    @page.add_embeddable(e)
    if e.instance_of?(Embeddable::MultipleChoice)
      e.create_default_choices
    end
    redirect_to edit_activity_page_path(@activity, @page)
  end

  def remove_embeddable
    PageItem.find_by_interactive_page_id_and_embeddable_id(params[:id], params[:embeddable_id]).destroy
    redirect_to edit_activity_page_path(@activity, @page)
  end

  private
  def set_page
    if params[:activity_id]
      @activity = LightweightActivity.find(params[:activity_id], :include => :pages)
      @page = @activity.pages.find(params[:id])
      # TODO: Exception handling if the ID'd Page doesn't belong to the ID'd Activity
    else
      # I don't like this method much.
      @page = InteractivePage.find(params[:id], :include => :lightweight_activity)
      @activity = @page.lightweight_activity
    end
  end
end
