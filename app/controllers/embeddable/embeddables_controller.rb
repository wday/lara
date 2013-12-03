class Embeddable::EmbeddablesController < ApplicationController
  def edit
    respond_with_edit_form
  end

  # PUT /Embeddable/xhtmls/1
  # PUT /Embeddable/xhtmls/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    if updated = @embeddable.update_attributes(params[@embeddable.class.name_as_param])
      update_activity_changed_by(@embeddable.activity) unless @embeddable.activity.nil?
      @embeddable.reload
    end
    respond_to do |format|
      if cancel || updated
        if request.xhr?
          format.xml { render :partial => 'show', :locals => { @embeddable.class.display_partial => @embeddable } }
        else
          flash[:notice] = "#{@embeddable.class.human_description} was successfully updated."
          format.html { redirect_to(request.env['HTTP_REFERER'].sub(/\?.+/, '')) } # Strip the edit-me param
          format.xml  { head :ok }
        end
      else
        format.html { render :edit }
        format.xml { render :xml => @embeddable.errors, :status => :unprocessable_entity }
      end
      format.json
    end
  end
end