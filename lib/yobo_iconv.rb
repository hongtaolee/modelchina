require  'iconv'
class YoboIconv 
  def self.iconv(str)
    begin
      return Iconv::conv("gbk//IGNORE","utf-8//IGNORE",str)      
    rescue Exception => e
      return ''
    end
  end
  
  def self.gb2utf(str)
    begin
      return Iconv::conv("utf-8//IGNORE","gbk//IGNORE",str)      
    rescue Exception => e
      return '' # TODO 相应调用的地方需要处理
    end
  end
  
  def self.utf2gbk(str)
    begin
      return Iconv::conv("gbk//IGNORE","utf-8//IGNORE",str)         
    rescue Exception => e
      return e
    end
  end  
end