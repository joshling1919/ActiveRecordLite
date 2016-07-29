require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = ""
    params.keys.each_with_index do |name, index|
      if index == params.keys.length - 1
        where_line << "#{name} = ?"
      else
        where_line << "#{name} = ? AND "
      end
    end
    p where_line

    array_of_matches = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    final_array = []
    array_of_matches.each do |hash_option|
      final_array << self.new(hash_option)
    end
    final_array
  end

end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
