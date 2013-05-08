class MwInteractive < ActiveRecord::Base
  attr_accessible :name, :url, :native_width, :native_height

  default_value_for :native_width, 576
  default_value_for :native_height, 435

  validates_numericality_of :native_width
  validates_numericality_of :native_height

  has_one :interactive_item, :as => :interactive
  has_one :interactive_page, :through => :interactive_item

  # returns the aspect ratio of the interactive, determined by dividing the width by the height.
  # So for an interactive with a native width of 400 and native height of 200, the aspect_ratio
  # will be 2. 
  def aspect_ratio
    if self.native_width && self.native_height
      return self.native_width/self.native_height.to_f
    else
      return 1.324 # Derived from the default values, above
    end
  end

  def height(width)
    return width/self.aspect_ratio
  end

  def to_hash
    # Deliberately ignoring user (will be set in duplicate)
    {
      name: name,
      url: url,
      native_width: native_width,
      native_height: native_height
    }
  end

  def duplicate
    # Generate a new object with those values
    new_interactive = MwInteractive.new(self.to_hash)
    # Clarify the name
    new_interactive.name = "Copy of #{new_interactive.name}"
    return new_interactive
    # N.B. the duplicate hasn't been saved yet
  end
end
