require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    "#{@class_name.downcase}s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    if options.empty?
      @foreign_key = "#{name}Id".underscore.to_sym
      @class_name = "#{name}".capitalize
      @primary_key = :id
    else
      @foreign_key = options[:foreign_key]
      @class_name = options[:class_name]
      @primary_key = options[:primary_key]
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    if options.empty?
      @foreign_key = "#{self_class_name}Id".underscore.to_sym
      @class_name = "#{name}".capitalize.singularize
      @primary_key = :id
    else
      @foreign_key = options[:foreign_key]
      @class_name = options[:class_name]
      @primary_key = options[:primary_key]
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    p name
    p options = BelongsToOptions.new(name)
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
