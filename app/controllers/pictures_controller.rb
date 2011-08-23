class PicturesController < ApplicationController
  def show
    img = Picture.find(params[:id])
    
    if img
      if params[:size]
        # resize the image to the passed :size
        
        # convert data to a usable RMagick image object
        data = Magick::Image.read(img.normal_path)[0]
        
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
        data = Magick::Image.read(img.normal_path)[0]
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
  
  end
  
end
