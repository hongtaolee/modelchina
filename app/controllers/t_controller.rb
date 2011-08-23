class TController < ApplicationController
  def haproxy
    now = (Time.now-1.days).to_s(:db)
    @yobo_pms = PageMonitorLog.find(:all, :conditions=>["created_at >=? and typee=? and result=0", now, 'yobo'])
    @yobo_pms.reverse!
    @baidu_pms = PageMonitorLog.find(:all, :conditions=>["created_at >=? and typee=? and result=0", now, 'baidu'])
    @baidu_pms.reverse!
  end
  
  def gen_haproxy_image
    require 'gruff'
    now = (Time.now-1.days).to_s(:db)
    yobo_pms = PageMonitorLog.find(:all, :conditions=>["created_at >=? and typee=? and result=0", now, 'yobo'])
    baidu_pms = PageMonitorLog.find(:all, :conditions=>["created_at >=? and typee=? and result=0", now, 'baidu'])
    g = Gruff::Line.new(1200)
    g.data('Yobo Pageload', yobo_pms.map{|pm| pm.duration})
    g.data('Baidu Pageload', baidu_pms.map{|pm| pm.duration})
    g.labels = {}
    0.upto(yobo_pms.size-1) do |i|
      if i % 180 == 0
        g.labels[i] = yobo_pms[i].created_at.strftime("%H:%M")
      else
        g.labels[i] = ' '
      end
    end
    
    filename = "#{RAILS_ROOT}/public/haproxy/haproxy.png"
    g.write(filename)
    send_file filename, :type => 'image/png', :disposition => 'inline'      
  end

end
