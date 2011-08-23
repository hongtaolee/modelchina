class OldImagesController < ApplicationController
  caches_page :show
  def show
    @headers['Cache-Control'] = 'public'
    img = OldImage.find(params[:id])
    
    if img
      if params[:size]
        data = Magick::Image.read(img.normal_path)[0]
        if params[:size].include? 'x'
          x, y = params[:size].split('x').collect(&:to_i)
        else
          x, y = params[:size].to_i, params[:size].to_i
        end
        
        if params[:dont_upscale]
          x = data.columns if x > data.columns
          y = data.rows    if y > data.rows
        end
        
        geometry = "#{x}x#{y}"
        
        case
          when params[:crop]
            data.crop_resized! x, y
          when params[:crop_without_resize]
            data.crop! Magick::CenterGravity, x, y
          else
            data.change_geometry!(geometry) {|cols, rows, img| img.resize!(cols, rows)}
        end
      else
        data = Magick::Image.read(img.normal_path)[0]
      end
      send_data data.to_blob, 
                :type => 'image/jpeg', 
                :disposition => 'inline'
    else
      render :nothing => true, :status => 404
    end
    GC.start
  end
end
