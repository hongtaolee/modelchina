module UserHelper

  def title_helper
    "#{@controller.controller_class_name} #{@controller.action_name}"
  end

  def start_form_tag_helper(options = {})
    url = url_for(:action => "#{@controller.action_name}")
    "#{self.send(:start_form_tag, url, options)}"
  end

  def attributes(hash)
    hash.keys.inject("") { |attrs, key| attrs + %{#{key}="#{h(hash[key])}" } }
  end

  def read_only_field(form_name, field_name, html_options)
    "<span #{attributes(html_options)}>#{instance_variable_get('@' + form_name)[field_name]}</span>"
  end

  def submit_button(form_name, prompt, html_options)
    %{<input name="submit" type="submit" value="#{prompt}" />}
  end

end
