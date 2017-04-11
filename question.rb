require_relative 'questions_db'
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
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
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

  def followers 
    QuestionFollow.followers_for_question_id(@id)
  end
end
