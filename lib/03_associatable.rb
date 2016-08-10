require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'
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
    @foreign_key = options[:foreign_key] || "#{name}Id".underscore.to_sym
    @class_name = options[:class_name] || "#{name}".capitalize
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name}Id".underscore.to_sym
    @class_name = options[:class_name] || "#{name}".capitalize.singularize
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method(name) do
      foreign_id = self.send(options.foreign_key) #foreign_key of 1
      model = options.model_class
      model.where(id: foreign_id).first
    end
  end

  def has_many(name, options = {})
    self_class_name = self.to_s
    options = HasManyOptions.new(name, self_class_name, options)
    define_method(name) do
      foreign_id = self.id
      model = options.model_class
      model.where(options.foreign_key => foreign_id)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
