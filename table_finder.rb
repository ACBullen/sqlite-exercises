# require_relative 'questions_db'
require 'active_support/inflector'
class TableFinder
  attr_reader :id, :table

  def initialize; end
  
  def self.table
    self.to_s.tableize
  end
  def save
    if @id
      self.update
    else
      self.create
    end
  end

  def self.all
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table}
    SQL

    data.map { |datum| self.new(datum) }
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, @table, id)
      SELECT
        *
      FROM
        ?
      WHERE
        id = ?
    SQL
    raise "Not in table" if data.empty?
    Question.new(data[0])
  end

end
