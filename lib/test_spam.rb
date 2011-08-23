class TestSpam
  
  KEYWORDS = ["酒店","服务员","服务生","服务人员","凤舞豪情","华丽天上","俱乐部","台费","公关","包养","天上人间","水晶宫","坐台","做台","夜总会","夜场","KTV","酒吧","办毕业证","恋足"]
  
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
