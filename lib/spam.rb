class Spam
  
  KEYWORDS = ["花场","酒店","VIP","俱","K T V","俱 乐 部","少爷","裸聊","公主","桑拿","时代国际","刚穿过的","夜店","公關","俱 乐 部","高薪","高 薪","商秘","公関","酒","服务员","服务生","服务人员","凤舞豪情","华丽天上","俱乐部","台费","公关","包养","花环","天上人间","水晶宫","坐台","做台","夜总会","夜场","KTV","酒吧","办毕业证","恋足"]
  
  def self.job(job_id)
    KEYWORDS.each do |k|
      eq = "%#{k}%"
      Job.delete_all(["id=? and (work like ? or content like ?)",job_id,eq,eq])
    end
  end

  def self.topic(topic_id)
    KEYWORDS.each do |k|
      eq = "%#{k}%"
      Topic.delete_all(["id=? and title like ?",topic_id, eq])
    end
  end

  def self.comment(comment_id)
    KEYWORDS.each do |k|
      eq = "%#{k}%"
      Comment.delete_all(["id=? and text like ?",comment_id, eq])
    end
  end

  def self.all
    KEYWORDS.each do |k|
      eq = "%#{k}%"
      Job.delete_all(["work like ? or content like ?",eq,eq])
      Topic.delete_all(["title like ?", eq])
      Comment.delete_all(["text like ?", eq])
    end
  end

  def self.remove_topic
    Topic.delete_all(["title is null"])
  end
end
