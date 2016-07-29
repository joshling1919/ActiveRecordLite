require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

  end

  def self.finalize!
    self.columns.each do |column|
      define_method "#{column}" do
        attributes[column]
      end

      define_method "#{column}=" do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= "#{self}".tableize
  end

  def self.all
      all_rows = DBConnection.execute(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name}
    SQL
    self.parse_all(all_rows)
  end

  def self.parse_all(results)
    final_array = []
    results
    results.each do |options_hash|
      options_hash
      final_array << self.new(options_hash)
    end
    final_array
  end

  def self.find(id)
    correct_row = DBConnection.execute(<<-SQL, id).first
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL

    self.new(correct_row) if correct_row
  end

  def initialize(params = {})
    params.each do |name, value|
      name_sym = name.to_sym
      if self.class.columns.include?(name_sym)
        self.send("#{name_sym}=", value)
      else
        raise "unknown attribute '#{name}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
      @attributes.values
  end

  def insert
    col = self.class.columns.drop(1)
    self.class.columns
    col_names = "(#{col.join(", ")})"
    question_marks = "("
      col.length.times do |index|
        if index < col.length - 1
          question_marks << "?, "
        else
          question_marks << "?)"
        end
      end

    DBConnection.execute(<<-SQL, *self.attribute_values)
      INSERT INTO
        #{self.class.table_name} #{col_names}
      VALUES
        #{question_marks}
    SQL

    attributes[:id] = DBConnection.last_insert_row_id

  end

  def update
    set_line = ""
    self.class.columns.drop(1).each_with_index do |col_name, index|
      if index == self.class.columns.drop(1).length - 1
        set_line << "#{col_name} = ?"
      else
        set_line << "#{col_name} = ?, "
      end
    end

    att_val = self.attribute_values.rotate

    DBConnection.execute(<<-SQL, *att_val)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL

  end

  def save
    if self.id.nil?
      self.insert
    else
      self.update
    end 
  end
end
