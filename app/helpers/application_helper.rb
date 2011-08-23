require_dependency 'mod_view'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def body_tag
    idname = controller.class.to_s.underscore.gsub(/_controller$/, '')
    classname = controller.action_name.underscore
    "<body id=\"#{idname}\" class=\"#{classname}\">"
  end
  
  def link_to_pages
    if @pages.page_count > 1
      page_code = "<div class='page_more'>"
      if @pages.current.previous
        page_code << "<span class='page'>#{link_to('上一页', { :page => @pages.current.previous })}</span>"
      end
      start_page = ((@pages.current.to_i+5) > @pages.page_count) ? @pages.page_count-9 : @pages.current.to_i-4
      end_page = @pages.current.to_i < 5 ? 10 : @pages.current.to_i + 5
      start_page = 1 if start_page < 1
      end_page = @pages.page_count if @pages.page_count < end_page
      for i in (start_page..end_page)
        if i == @pages.current.to_i
        page_code << "<span class='page' id='current_page'>#{i}</span>"
        else
        page_code << "<span class='page'>#{link_to i, { :page => i }}</span>"
        end
     end 
     l = @pages.page_count - end_page
     case l
     when 0    
     when 1
         page_code << "<span class='page'>#{link_to @pages.page_count,{:page => @pages.page_count}}</span>"    
     when 2
         page_code << "<span class='page'>#{link_to @pages.page_count - 1 ,{:page => @pages.page_count - 1}}</span>" 
         page_code << "<span class='page'>#{link_to @pages.page_count,{:page => @pages.page_count}}</span>"     
     else
         page_code << "<span class='page' id='more_page'>...</span>"
         page_code << "<span class='page'>#{link_to @pages.page_count - 1,{:page => @pages.page_count - 1}}</span>" 
         page_code << "<span class='page'>#{link_to @pages.page_count,{:page => @pages.page_count}}</span>"     
     end
     if @pages.current.next
        page_code << "<span class='page'>#{link_to('下一页', { :page => @pages.current.next })}</span>"
     end
     page_code << "</div>"  
     return page_code
    end
  end
  
  def link_to_avata(object,size = nil,controller = "#{object.class.to_s.underscore}s",action = 'show')
    if object.avata
      if File.file? object.avata.normal_path
      return link_to(image_tag(url_for(:controller=>'avatas',
                              :action=>'show',
                              :id =>object.avata,
                              :size => size),
                             :id => 'image_preview',
                             :alt => object.name),
                             :controller => controller,
                             :action=> action,
                             :id=>object.id)
      else
      return link_to(image_tag(url_for(:controller=>'avatas',:action=>'show',:id=>235,:size => size),:id => 'image_preview'),
                             :controller => controller,
                             :action=> action,
                             :id=>object.id)      
      end
    else
      return link_to(image_tag(url_for(:controller=>'avatas',:action=>'show',:id=>235,:size => size),:id => 'image_preview'),
                             :controller => controller,
                             :action=> action,
                             :id=>object.id)
    end   
  end
  
  def current_controller
    return controller.class.to_s.underscore.gsub(/_controller$/, '')
  end
  
  def current_action
    return controller.action_name.underscore
  end
  
  def tag_cloud(tag_cloud, category_list)
    max, min = 0, 0
    tag_cloud.each do |tag, count|
      max = count if count > max
      min = count if count < min
    end

    divisor = ((max - min) / category_list.size) + 1

    tag_cloud.each do |tag, count|
      yield tag, category_list[(count - min) / divisor] 
    end
  end
  
  protected 

  def format_datetime(datetime)
    datetime.strftime "%Y-%m-%d %H:%M"
  end
  def format_relative_time(time)
    interval = (Time.now - time)
    seconds = (interval).to_i
    minutes = (interval / 60).to_i
    hours = (interval / (60*60)).to_i
    days = (interval / (60*60*24)).to_i

    if days == 0
      if hours == 0
        if minutes == 0
          return "#{seconds}秒前"
        end
        return "#{minutes}分钟前"
      end
      return "#{hours}小时前"
    end
    
    if days == 1
      return '昨天'
    else
      return "#{days}天前"
    end
  end    
  # Useful abstraction for form input fields - combines an input field with error message (if any)
  # and writes an appropriate style (for errors)
  # Usage:
  #   form_input :text_field, 'postform', 'subject'
  #   form_input :text_area, 'postform', 'text', 'Please enter text:', 'cols' => 80
  #   form_input :hidden_field, 'postform', 'topic_id'
  def form_input(helper_method, form_name=nil, field_name=nil, prompt = field_name.capitalize, remark = nil, options = {},must = nil)
    remark_out = ""
    if remark
      remark_out << "#{remark}"
    end    
    case helper_method.to_s
    when 'hidden_field'
      self.hidden_field(form_name, field_name, options)
    when /^.*button$/
      <<-EOL
      <tr class="two_columns"><td class="prompt"></td><td class="button" colspan="2">
        #{self.send(helper_method, form_name, prompt, options)}#{remark_out}
      </td></tr>
      EOL
    else
      field = (
        if :select == helper_method
          self.send(helper_method, form_name, field_name, options.delete('values'), options)
        else
          self.send(helper_method, form_name, field_name, options)
        end)
      if options['class'] == 'single_columns'
        <<-EOL
        <tr><td class="prompt" valign="top"><label>#{prompt}�:#{remark_out}</label></td></tr>
        <tr><td class="value">#{field}</td></tr>
        EOL
      else
        <<-EOL
        <tr class="two_columns">
          <td class="prompt" valign="top"><label>#{prompt}:</label></td>
          <td class="value">#{field}</td>
        </tr>
        <tr><td></td><td class="remark #{'font_red' if must == 'true'}">#{remark_out}</td></tr>
        EOL
      end
    end
  end

  # Helper method that has the same signature as real input field helpers, but simply displays 
  # the value of a given field enclosed within <p> </p> tags.
  # Usage:
  #   <%= form_input :read_only_field, 'user', 'name', _("user_name")) %>
  def read_only_field(form_name, field_name, html_options)
    "<span #{attributes(html_options)}>#{instance_variable_get('@' + form_name)[field_name]}</span>"
  end

  def submit_button(form_name, prompt, html_options)
    %{<input name="submit" type="submit" value="#{prompt}" />}
  end
     def hl(*value)
        if(value.length == 1)
          if value[0].class == Array
            format = value[0].shift
            html_escape(sprintf(l(format), *value[0]))
          else
            html_escape(l(value[0]))
          end
        else
          format = value.shift
          html_escape(sprintf(l(format), *value))
        end
      end

      def l(str)
        return '' if str.nil?
        return str unless str.class == String
        str.gsub(/(\[+)(_)?([a-zA-Z0-9_]*)(\]+)/){
          if $2.nil?
            $1 + $3 + $4
          elsif $1.length > 1 || $4.length > 1
            $1.chop + $2 + $3 + $4.chop
          else
#            RubricksLib.lang[$2 + $3]
          end
        }
      end
      
  def changeable(user, field)
    if user.new_record? or LoginEngine.config(:changeable_fields).include?(field)
      :text_field
    else
      :read_only_field
    end
  end 
 
  def valid_email?(email)
    email.size < 100 && email =~ /.@.+\../ && email.count('@') == 1
  end
  
  def corner(id,color,bgcolor,compact,corners="all")
    javascript_tag("Rico.Corner.round('#{id}', {color: '#{color}', bgColor: '#{bgcolor}', compact: #{compact}, corners: '#{corners}'});")
  end
  
  def human_datetime(datetime)
    distance_in_minutes = (((Time.now - datetime).abs)/60).round
    case distance_in_minutes
      when 0..1           then '1 分钟前'
      when 2..59          then "#{distance_in_minutes} 分钟前"
      when 60..1440       then datetime.strftime("%H:%M:%S")
      else datetime.strftime("%Y-%m-%d")
    end
  end

  def my_truncate(text, length = 30, truncate_string = "...")
    if text.blank? then return "" end
    if $KCODE == "NONE"
      (return text) if text.length <= length*2
    else
      chars = text.split(//)
      (return text) if chars.length <= length
    end
    l = length - truncate_string.length
         
    reg = /[[:print:]]/ # any printable character
    result = ""
    pos = 0
    chars = text.split(//)         
    chars.each do |cc|
      pos += 0.5
      pp = (reg =~ cc)
      pos += 0.5 unless pp
      (result << cc) if pos<length-0.5
    end
    (return text) if text.length<=result.length
    return (result + truncate_string)
  end
  
  def fmt_percentage(d1, d2)
    if d2 > 0
      sprintf("%.1f%%", d1*100.00 / d2)
    else
      "NaN"
    end
  end
  
  def w3c_date(date)
    unless date.blank?
      date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
    else
      Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
    end
  end
  
  def meta_helper
    out = <<-EOF
      <title>#{h @page_title ? @page_title+' - 模特中国网' : '模特中国网'}</title>
      <meta  name="keywords" content="#{h @page_keywords.join(',')+',' if !@page_keywords.blank?}模特,男模特,女模特,走秀,T台模特,脚模特,手模特" />
      <meta name="description" content="#{(h(!@page_description.blank? ? @page_description : Enum::WEB_DESCRIPTION).gsub(/\s/,' '))}" />
    EOF
  end
end
