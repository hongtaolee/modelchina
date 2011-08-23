module SuperImagePlugin
  module Show
    
    def self.included(base)
      base.extend ClassMethods
      base.class_eval {image_action :show_image} # keeps backwards compatibility for when image_action is not explicitly called.
    end
    
    module ClassMethods
      
      # Defines the controller action that shows an image.  First include the plugin to your 
      # controller, then pass in the name of the action you want to use display images.
      #
      #   ImagesController < ApplicationController
      #     include SuperImagePlugin::Show
      #     image_action :show_a_pretty_picture
      #   end
      #
      # Then use the +show_a_pretty_picture+ action on that controller to see your images like 
      # <tt>/my_controller_name/show_a_pretty_picture/9</tt>.  Pass a <tt>:size</tt> parameter 
      # in the URL to set the size of the image.
      def image_action(method_name)
        define_method(method_name) {
#          @headers['Cache-Control'] = 'public'
          
          # Get image object
          img = (defined?(@@super_image_class) ? @@super_image_class : SuperImage).find(params[:id])
          
          if img
            if params[:size]
              # resize the image to the passed :size
              
              # convert data to a usable RMagick image object
              data = Magick::Image.from_blob(img.data)[0]
              
              # Find dimensions
              if params[:size].include? 'x'
                x, y = params[:size].split('x').collect(&:to_i)
              else
                x, y = params[:size].to_i, params[:size].to_i
              end
              
              # prevent upscaling if :no_upscale param exists.
              if params[:dont_upscale]
                x = data.columns if x > data.columns
                y = data.rows    if y > data.rows
              end
              
              # Create geometry string
              geometry = "#{x}x#{y}"
              
              # Perform image manipulation
              case
                when params[:crop]
                  # perform resize and crop
                  data.crop_resized! x, y
                when params[:crop_without_resize]
                  # perform crop without resize
                  data.crop! Magick::CenterGravity, x, y
                else
                  # perform the resize operation
                  data.change_geometry!(geometry) {|cols, rows, img| img.resize!(cols, rows)}
              end
            else
              # no resize, just pass along image data
              data = Magick::Image.from_blob(img.data)[0]
            end
            
            # Send image data to the browser.
            send_data data.to_blob, 
                      :type => 'image/jpeg', 
                      :disposition => 'inline'
          else
            # if no image was found, render a 404.
            render :nothing => true, :status => 404
          end
          GC.start
        }
      end
      
      # If not using SuperImage as the image model, set the class with this method.  Pass in the actual
      # class, not just the name.
      def image_class(class_name)
        @@super_image_class = class_name
      end
    end # Class Methods
  end # Show
  
  module SetImage
    
    # Sets the data field in the database to an uploaded file.  Can also be invoked indirectly
    # via <tt>SuperImage.create(:data => params[:image][:data])</tt> or even <tt>SuperImage.new(params[:image])</tt>
    def data=(file)
      if file.size > 0
        img = Magick::Image.from_blob(file.read)[0]
        img.format = 'JPG'
        self[:data] = img.to_blob
      end
      GC.start
    end
  end # SetImage
end # SuperImagePlugin

class SuperImage < ActiveRecord::Base
  include SuperImagePlugin::SetImage
end