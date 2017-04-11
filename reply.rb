require_relative 'questions_db'

class Reply
  attr_reader :id
  attr_accessor :question_id, :user_id, :parent_reply, :body

  def initialize(options)
    @id = options["id"]
    @question_id = options["question_id"]
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
    Reply.new(data[0])
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
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    raise "Not in table" if data.empty?
    data.map { |datum| Reply.new(datum) }
  end

  def update
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id, @parent_reply, @body, @id)
      UPDATE
        replies(user_id, question_id, parent_reply, body)
      VALUES
        (?, ?, ?, ?)
      WHERE
        id = ?
    SQL
  end

  def create
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id, @parent_reply, @body)
      INSERT INTO
        replies(user_id, question_id, parent_reply, body)
      VALUES
        (?, ?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_reply)
  end

  def child_replies
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply = ?

    SQL
    raise "no children" if data.empty?
    data.map { |datum| Reply.new(datum) }
  end

end
