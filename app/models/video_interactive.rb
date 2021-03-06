class VideoInteractive < ActiveRecord::Base
  has_one :interactive_item, :as => :interactive, :dependent => :destroy
  # InteractiveItem is a join model; if this is deleted, that instance should go too
  has_one :interactive_page, :through => :interactive_item
  has_many :sources, :class_name => 'VideoSource',
           :foreign_key => 'video_interactive_id',
           :dependent => :destroy # If we delete this video we should dump its sources

  attr_accessible :poster_url, :caption, :credit, :height, :width, :sources_attributes

  accepts_nested_attributes_for :sources, :allow_destroy => true

  validates_numericality_of :height, :width

  def self.string_name
    "video interactive"
  end

  # returns the aspect ratio of the interactive, determined by dividing the width by the height.
  # So for an interactive with a native width of 400 and native height of 200, the aspect_ratio
  # will be 2.
  def aspect_ratio
    if self.width && self.height
      return self.width/self.height.to_f
    else
      return 1.324 # Derived from the default values, above
    end
  end

  def calculated_height(width)
    return width/self.aspect_ratio
  end

  def activity
    if interactive_page
      return self.interactive_page.lightweight_activity
    else
      return nil
    end
  end

  def to_hash
    {
      poster_url: poster_url,
      caption: caption,
      credit: credit,
      height: height,
      width: width
    }
  end

  def duplicate
    vi = VideoInteractive.new(self.to_hash)
    vi.sources = self.sources.map { |vs| vs.duplicate }
    return vi
  end
end
