class VideoInteractivesController < InteractiveController
  before_filter :set_interactive, :except => [:new, :create]

  def edit
    if @interactive.sources.length < 1
      @interactive.sources << VideoSource.new() # If we don't have one, weird stuff happens
    end
    super
  end

  def add_source
    @source = VideoSource.new(:video_interactive => @interactive)
    @interactive.reload
    update_activity_changed_by(@interactive.activity) unless @interactive.activity.nil?
    respond_to do |format|
      if request.xhr?
        format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
      else
        flash[:notice] = 'New source was added.'
        format.html { redirect_to(:back) }
        format.xml  { head :ok }
        format.json
      end
    end
  end

  def remove_source
    @interactive.video_sources.find(params[:source_id]).destroy
    @interactive.reload
    update_activity_changed_by(@interactive.activity) unless @interactive.activity.nil?
    respond_to do |format|
      if request.xhr?
        format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
      else
        flash[:notice] = 'Source removed.'
        format.html { redirect_to(:back) }
        format.xml  { head :ok }
        format.json
      end
    end
  end

  private
  def set_interactive
    @interactive = VideoInteractive.find(params[:id])
    set_page
  end

  def create_interactive
    @interactive = VideoInteractive.create!()
    @interactive.sources << VideoSource.new() # If we don't have one, weird stuff happens
    @params = { edit_vid_int: @interactive.id }
  end

  def get_interactive_params
    @input_params = params[:video_interactive]
  end
end
