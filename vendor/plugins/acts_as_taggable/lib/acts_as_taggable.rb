module ActiveRecord
  module Acts #:nodoc:
    module Taggable #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)  
      end
      
      module ClassMethods
        def acts_as_taggable(options = {})
          write_inheritable_attribute(:acts_as_taggable_options, {
            :taggable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s,
            :from => options[:from]
          })
          
          class_inheritable_reader :acts_as_taggable_options

          has_many :taggings, :as => :taggable, :dependent => true
          has_many :tags, :through => :taggings

          include ActiveRecord::Acts::Taggable::InstanceMethods
          extend ActiveRecord::Acts::Taggable::SingletonMethods          
        end
      end
      
      module SingletonMethods
#        def find_tagged_with(list)
#          find_by_sql(
#            "SELECT #{table_name}.* FROM #{table_name}, tags, taggings " +
#            "WHERE #{table_name}.#{primary_key} = taggings.taggable_id " +
#            "AND taggings.taggable_type = '#{acts_as_taggable_options[:taggable_type]}' " +
#            "AND taggings.tag_id = tags.id AND tags.name IN (#{list.collect { |name| "'#{name}'" }.join(", ")})"
#          )
#        end
				def find_tagged_with(options)
					sql = "SELECT * FROM tags, taggings, #{table_name} " 
					sql << "WHERE taggings.taggable_id = #{table_name}.#{primary_key} AND taggings.tag_id = tags.id " 
					sql << "AND #{sanitize_sql(options[:conditions])} " if options[:conditions]
#					sql << " GROUP BY tags.name "
					sql << "HAVING count #{options[:count]} " if options[:count] 
					sql << "ORDER BY #{options[:order]} " if options[:order] 
					sql << "LIMIT #{options[:limit]} " if options[:limit] 
					result = find_by_sql(sql) 
				end
				
				def tags_count(options) 
					sql = "SELECT tags.id AS id, tags.name AS name, COUNT(*) AS count FROM tags, taggings, #{table_name} " 
					sql << "WHERE taggings.taggable_id = #{table_name}.#{primary_key} AND taggings.tag_id = tags.id " 
					sql << "AND #{sanitize_sql(options[:conditions])} " if options[:conditions]
					sql << " GROUP BY tags.name "
					sql << "HAVING count #{options[:count]} " if options[:count] 
					sql << "ORDER BY #{options[:order]} " if options[:order] 
					sql << "LIMIT #{options[:limit]} " if options[:limit] 
					result = find_by_sql(sql) 
					count = result.inject({}) { |hsh, row| hsh[row['name']] = row['count'].to_i; hsh } unless options[:raw] 
					count || result 
			end 
      end
      
      module InstanceMethods
        def tag_with(list)
          Tag.transaction do
            taggings.destroy_all

            Tag.parse(list).each do |name|
              if acts_as_taggable_options[:from]
                send(acts_as_taggable_options[:from]).tags.find_or_create_by_name(name).on(self)
              else
                Tag.find_or_create_by_name(name).on(self)
              end
            end
          end
        end

        def tag_list
          tags.collect { |tag| righttag.name.include?(" ") ? "'#{tag.name}'" : tag.name }.join(" ")
        end
      end
    end
  end
end