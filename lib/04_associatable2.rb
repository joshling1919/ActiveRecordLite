require_relative '03_associatable'

module Associatable

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_object = self.send(through_name)
      through_object.send(source_name)
    end
  end
end
