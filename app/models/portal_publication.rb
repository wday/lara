class PortalPublication < ActiveRecord::Base
  attr_accessible :portal_url, :response, :success
  # Assuming portals aren't a first-class model - representing them by their URLs

  # What got published - usually one of these, not both
  belongs_to :lightweight_activity
  belongs_to :sequence
end