module LightweightActivityHelper
  def toggle_all(label='all', id_prefix='details_')
    link_to_function("show/hide #{label}", "$('div[id^=#{id_prefix}]').toggle();")
  end

  def has_good_content(value)
    return false if value.nil?
    related = value.gsub(/(<([^>]+)>)/,'')
    return (!related.blank?)
  end

  def runnable_activity_path(activity)
    if @sequence_run
      run = @sequence_run.run_for_activity(activity)
      activity_with_response_path(activity.id, run.key)
    elsif @sequence
      sequence_activity_path(@sequence, activity)
    else
      activity_path(activity)
    end
  end

  # TODO i18n!
  def activity_name_for_menu
    results = "ACTIVITY"
    if @sequence
      results << " #{@activity.position(@sequence)}"
    end
    return "#{results}: #{@activity.name}"
  end
end
