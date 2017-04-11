require 'sqlite3'
require 'singleton'
class QuestionsDatabase < SQLite3::Database
  include Singleton
  def initialize
    super("questions.db")
    @results_as_hash = true
    @type_translation = true
  end
end

class Question
  attr_reader :id
  attr_accessor :user_id, :title, :body

  def initialize(options)
    @id = options["id"]
    @user_id = options["user_id"]
    @title = options["title"]
    @body = options["body"]
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    raise "Not in table" if data.empty?
    Question.new(data[0])
  end

  def self.find_by_title(title)
    data = QuestionsDatabase.instance.execute(<<-SQL, title)
      SELECT
        *
      FROM
        questions
      WHERE
        title = ?
    SQL
    raise "Not in table" if data.empty?
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instane.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?

    SQL
    raise "Not in table" if data.empty?
    data.map { |datum| Question.new(datum) }
  end

  def update
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @title, @body, @id)
      UPDATE
        questions(user_id, title, body)
      VALUES
        (?, ?, ?)
      WHERE
        id = ?
    SQL
  end

  def create
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @title, @body)
      INSERT INTO
        questions(user_id, title, body)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def author
    User.find_by_id(@user_id)
  end

  def replies
    Replies.find_by_question_id(@id)
  end
end


class User
  attr_reader :id
  attr_accessor :fname, :lname

  def initialize(options)
    @id = options["id"]
    @fname = options["fname"]
    @lname = options["lname"]
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    raise "Not in table" if data.empty?
    Question.new(data[0])
  end

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    raise "Not in table" if data.empty?
    data.map { |datum| Question.new(datum) }
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def update
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users(fname, lname)
      VALUES
        (?, ?)
      WHERE
        id = ?
    SQL
  end

  def create
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users(fname, lname)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

end

class Reply
  attr_reader :id
  attr_accessor :question_id, :user_id, :parent_reply, :body

  def initialize(options)
    @id = options["id"]
    @question_id = options["quesiton_id"]
    @user_id = options["user_id"]
    @parent_reply = options["parent_reply"]
    @body = options["body"]
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    raise "Not in table" if data.empty?
    Question.new(data[0])
  end

  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    raise "Not in table" if data.empty?
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        quesiton_id = ?
    SQL
    raise "Not in table" if data.empty?
    data.map { |datum| Question.new(datum) }
  end

  def update
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @title, @body, @id)
      UPDATE
        questions(user_id, title, body)
      VALUES
        (?, ?, ?)
      WHERE
        id = ?
    SQL
  end

  def create
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @title, @body)
      INSERT INTO
        replies(user_id, title, body)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end
end
