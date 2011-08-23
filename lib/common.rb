class Array
  def random(n)
  	rand_array = []
  	n.downto(1) {|i| rand_array << delete_at(rand(size-i))}
  	rand_array
  end
end
class String
  def escape_single_quotes
    gsub(/[']/, '\\\\\'')
  end
end
module Enumerable
  def sort_by_frequency
    group = inject(Hash.new(0)) { |hash, x| hash[x] += 1; hash}
    sort_by { |x| [-group[x], x] }
  end
  def group_by_frequency
    group = inject(Hash.new(0)) { |hash, x| hash[x] += 1; hash}
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

def rc4(text,key)
   keys = []
   cyphers = []
   for i in 0 .. 255
	keys[i] =  key[i % key.size]
	cyphers[i] = i
   end
#   puts keys.join(',')
#   puts cyphers.join(',')

   jump = 0
   for i in 0..255
	   jump = (jump + cyphers[i] + keys[i]) & 0xFF
	   cyphers[i] , cyphers[jump] = cyphers[jump], cyphers[i]
   end
#   puts cyphers.join(',') 
    i = 0
    jump = 0
    for c in 0 .. text.size # 处理中文
      puts c
      i = (i + 1) & 0xff
      jump = (jump + cyphers[i]) & 0xff
      t = (cyphers[i] + cyphers[jump]) & 0xff
#      puts "#{c}~~#{t}"
      cyphers[i], cyphers[jump] = cyphers[jump], cyphers[i]
      text[c] ^= cyphers[t]
    end
    text
end

def is_spider
  btime = Time.new
  return true if request.user_agent.blank?
  user_agent = request.user_agent.downcase
  logger.debug("user_agent #{user_agent}")
  is_spider = false
  Enum::SPIDER.each do |s|
    if user_agent.match(s)
      is_spider = true
      break
    end
  end
  etime = Time.new
  logger.debug("cost of is_spider check: #{etime - btime}")
  return is_spider
end

