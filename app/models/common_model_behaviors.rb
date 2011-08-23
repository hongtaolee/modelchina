class ActiveRecord::Base

  def check_mandatory_atributes(*attributes)
    attributes.each do |attr|
      value = self.send(attr.to_sym)
      if value.nil? or value.to_s.empty?
        raise ArgumentError.new("Mandatory attribute #{attr} is not set") 
      end
    end
  end

  # Returns the first row retrieved by find_by_sql(query).
  # Raises ActiveRecord::RecordNotFound if no rows were found
  def self.find_first_by_sql(query)
    result = find_by_sql(query)
    if result.empty?
      raise ActiveRecord::RecordNotFound.new("Couldn't find #{self} specified by query") 
    end
    return result.first
  end

  # Checks if a string may be a real email or not
  def valid_email?(email)
    email.size < 100 && email =~ /.@.+\../ && email.count('@') == 1
  end

end

class ActiveRecord::Errors
  # Duplicate check
  def add_on_duplicate(attributes, msg = 'with same value already exists')
    # if this save is an update, not a create, then duplicate name/email check should obviously 
    # exclude the existing record that is being updated
    not_same_id_clause = ''
    not_same_id_clause = "AND id <> #{@base.id}" unless @base.new_record?
    [attributes].flatten.each { |attr| 
      if @base.class.find_first ["#{attr} = '%s' #{not_same_id_clause}", @base[attr]]
        add(attr, msg)
      end
    }
  end

end

# All model classes must raise App::ValidationError on errors by including this 
# mixin. If after_validation is overriden in the class, it should call the mixin 
# version like this:
#
#  alias :error_raising_after_validation :after_validation
#  ...
#  def after_validation
#    ...
#    ... validations, no return from the middle ...
#    ...
#    error_raising_before_validation_on_create
#  end

# Error class to raise on errors in validate
module App 
  class ValidationError < StandardError
    attr_reader :entity
  
    def initialize(entity)
      @entity = entity
    end
    
    def errors
      @entity.errors
    end
    
    def message
      s = "Problems with #{@entity.class} ##{@entity.id || 'nil'} :\n"
      @entity.errors.each { |attr, msg| 
        s << "    #{attr} : #{msg} (value: #{@entity.send(attr.to_sym) || 'nil'})\n" 
      }
      s
    end

    def to_s
      "#{self.class} : #{message}"
    end

  end
end

# If this module is included in an AR class, App::ValidationError is raised
# after validation if there were any validation errors.
module ErrorRaising
  def after_validation
    raise App::ValidationError.new(self) unless self.errors.empty?
  end
end
