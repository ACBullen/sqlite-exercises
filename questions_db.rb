require 'sqlite3'
require 'singleton'
require_relative 'user'
require_relative 'question'
require_relative 'reply'
require_relative 'question_follows'
require_relative 'question_like'

class QuestionsDatabase < SQLite3::Database
  include Singleton
  def initialize
    super("questions.db")
    @results_as_hash = true
    @type_translation = true
  end
end
