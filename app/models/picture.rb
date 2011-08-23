class Picture < ActiveRecord::Base
  attr_writer :data
  attr_reader :thumb_link
  after_create :generate_images
  before_destroy :remove_images 
  has_one :model_picture, :dependent => :destroy
  has_one :photographer_picture, :dependent => :destroy
  has_one :makeup_picture, :dependent => :destroy 

  def generate_images
    if @data.length > 0
      File.open(picture_path, "wb") do |f|
        f.write(@data.read)
      end
         
      # Generate the normalimage
      normal = Image.read(picture_path)[0]
      if normal.columns > normal.rows
        scale = 600 * normal.rows / normal.columns
        normal.scale!(600, scale)
      else
        scale = 400 * normal.columns / normal.rows
        normal.scale!(scale, 400)
      end
      normal.format = 'JPG'
      normal.write(normal_path)
    end
  end
  
  def remove_images
    FileUtils.rm [ picture_path, normal_path ]
  end
    
#  def data=(file)
#    if file.size > 0
#      img = Magick::Image.from_blob(file.read)[0]
#      img.format = 'JPG'
#      self[:data] = img.to_blob
#    end
#    GC.start
#  end

  def thumb_link
    "/images/pictures/#{self.id}.jpg"
  end
  
  def picture_path
    "#{RAILS_ROOT}/public/images/pictures/source/#{self.id}.jpg"
  end
  
  def normal_path
    "#{RAILS_ROOT}/public#{thumb_link}"  
  end
end
