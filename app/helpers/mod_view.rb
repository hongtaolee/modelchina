module ActionView
  include ERB::Util

  class Base
    def render_file(template_path, use_full_path = true, local_assigns = {})

      # ---- Begin personal additions to Rails core
      # First, make sure this partial doesn't already exist as a mod (only supports .rhtml right now)
      if FileTest.exists?( "#{RAILS_ROOT}/modules/views/#{template_path}.rhtml" )
          template_path = "../../modules/views/#{template_path}"
      end
      # ---- End personal additions to rails core

      @first_render      = template_path if @first_render.nil?

      if use_full_path
        template_extension = pick_template_extension(template_path)
        template_file_name = full_template_path(template_path, template_extension)
      else
        template_file_name = template_path
        template_extension = template_path.split(".").last
      end
      
      # If we were to inject into the source, I beleive we would do it here
      template_source = read_template_file(template_file_name, template_extension)

      begin
        render_template(template_extension, template_source, template_file_name, local_assigns)
      rescue Exception => e
        if TemplateError === e
          e.sub_template_of(template_file_name)
          raise e
        else
          raise TemplateError.new(@base_path, template_file_name, @assigns, template_source, e)
        end
      end
    end

  end

end


