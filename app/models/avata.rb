class Avata < ActiveRecord::Base
  attr_writer :data
  attr_reader :thumb_link
  after_create :generate_images,:generate_id
  before_destroy :remove_images  
  def generate_id
    unless self.group_id
      if self.user_id
        owner = User.find(self.user_id)
        case owner.category
        when 1
          self.model_id = owner.models.first.id
        when 2
          self.enterprise_id = owner.enterprise
        when 3
          self.photographer_id = owner.photographers.first.id
        when 4
          self.makeup_id = owner.makeups.first.id
        end
      end
      self.save
    end
  end
  
  def generate_images
    if @data.size > 0
      File.open(picture_path, "wb") do |f|
        f.write(@data.read)
      end        
      # Generate the normalimage
      normal = Image.read(picture_path)[0]
      if normal.columns > normal.rows
        scale = 80 * normal.rows / normal.columns
        normal.scale!(80, scale)
      else
        scale = 100 * normal.columns / normal.rows
        normal.scale!(scale, 100)
      end
      normal.format = 'JPG'
      normal.write(normal_path)
    end
  end
  
  def update_image(image_data)
    if image_data.size > 0
      File.open(picture_path, "wb") do |f|
        f.write(image_data.read)
      end        
      # Generate the normalimage
      normal = Image.read(picture_path)[0]
      if normal.columns > normal.rows
        scale = 80 * normal.rows / normal.columns
        normal.scale!(80, scale)
      else
        scale = 100 * normal.columns / normal.rows
        normal.scale!(scale, 100)
      end
      normal.format = 'JPG'
      normal.write(normal_path)
    end
  end
    
  def remove_images
    FileUtils.rm [ picture_path, normal_path ] if File.file? normal_path
  end
  
#  def data=(file)
#    if file.size > 0
#      img = Magick::Image.from_blob(file.read)[0]
#      if img.columns > img.rows
#        scale = 80 * img.rows / img.columns
#        img.scale!(80, scale)
#      else
#        scale = 100 * img.columns / img.rows
#        img.scale!(scale, 100)
#      end
#      img.format = 'JPG'
#      self[:data] = img.to_blob
#    end
#  end
  
  def thumb_link
    "/images/avatas/#{self.id}.jpg"
  end
  
  def picture_path
    "#{RAILS_ROOT}/public/images/avatas/source/#{self.id}.jpg"
  end
  
  def normal_path
    "#{RAILS_ROOT}/public#{thumb_link}"  
  end
end