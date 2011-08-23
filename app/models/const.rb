class Const < ActiveRecord::Base

  def self.display_name(table,field,value)
    find(:first,:conditions=>['table_name = ? and field_name =? and field_value = ?',table,field,value]).text_name
  end
end
