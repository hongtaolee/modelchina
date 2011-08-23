require 'socket'
require 'net/http'
require 'uri'
require 'yaml'

class MTask
  def self.monit_page_load
    timeout = 30
    pages = [['yobo', "http://www.yobo.com/artist/index/407/", "周杰伦"],
             ['baidu', "http://news.baidu.com/", YoboIconv.utf2gbk("焦点新闻")]]
    pages.each do |p|
      ptypee = p[0]
      purl = p[1]
      pkeyword = p[2]
      url = URI.parse(purl)
      pml = PageMonitorLog.new
#      pml.keyword = pkeyword
      pml.url = purl
      pml.timeout = timeout
      pml.typee = ptypee
      begin
        start_time = Time.now
        res = Net::HTTP.start(url.host, url.port) do |http|
          http.read_timeout = timeout
          http.get(url.path)
        end
        duration = Time.now - start_time
        body = res.body
  
        pml.response = res.code
        pml.duration = duration
        
        case res
        when Net::HTTPOK
          if body.include? pkeyword
             pml.result = 0
          else
             pml.result = -1
          end
        else
          pml.result = -2
        end
      rescue Exception => e
        pml.result = -3
        pml.info = e.to_s
      end
      pml.save(false)
    end
  end
end