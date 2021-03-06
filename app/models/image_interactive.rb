class ImageInteractive < ActiveRecord::Base
  attr_accessible :url, :caption, :credit, :show_lightbox

  has_one :interactive_item, :as => :interactive, :dependent => :destroy
  # InteractiveItem is a join model; if this is deleted, that instance should go too

  has_one :interactive_page, :through => :interactive_item

  def self.string_name
    "image interactive"
  end

  def to_hash
    {
      url: url,
      caption: caption,
      credit: credit
    }
  end

  def duplicate
    return ImageInteractive.new(self.to_hash)
  end
end
