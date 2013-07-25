module ConcordPortalPublishing

  def portal_url
    (ENV['CONCORD_PORTAL_URL'] || "http://localhost:3000") + '/external_activities/publish/v2'
  end

  # publish an activity or sequence to the portal
  def portal_publish(publishable)

    # TODO: better error handling
    raise "#{publishable.class.name} is Not Publishable" unless publishable.respond_to?(:serialize_for_portal)

    name, local_url = case publishable.class.name
                      when 'Sequence'
                        # Sequence doesn't have a name, use title
                        [publishable.title, sequence_url(publishable) ]
                      when 'LightweightActivity'
                        [publishable.name,  activity_url(publishable) ]
                      end

    data = publishable.serialize_for_portal(local_url)


    bearer_token = 'Bearer %s' % current_user.authentication_token
    logger.info "Attempting to publish #{publishable.class.name} #{name} to #{portal_url}."
    logger.info "Data will be #{data.to_json}"
    logger.info "Auth header will use #{bearer_token}."
    response = HTTParty.post(portal_url, :body => data.to_json, :headers => {"Authorization" => bearer_token, "Content-Type" => 'application/json'})
    # report success or put details in flash
    logger.info "Response: #{response.inspect}"
    if response.code == 201
      return true
    else
      flash[:alert] = "Got response code #{response.code} from the portal: #{response.message}"
      return false
    end

  end
end
