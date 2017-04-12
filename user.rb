# require_relative 'questions_db'

class User < TableFinder
  attr_accessor :fname, :lname

  def initialize(options)
    @table = 'users'
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
    User.new(data[0])
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
    data.map { |datum| User.new(datum) }
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

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def follow_question(question_id)
    QuestionsDatabase.instance.execute(<<-SQL, @id, question_id)
      iNSERT INTO
        question_follows (user_id, question_id)
      VALUES
        (?, ?)
    SQL
  end

  def like_question(question_id)
    QuestionsDatabase.instance.execute(<<-SQL, @id, question_id)
      iNSERT INTO
        question_likes (user_id, question_id)
      VALUES
        (?, ?)
      SQL
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        COUNT(DISTINCT(question_id)) as num_q, CAST(COUNT(question_likes.id) as FLOAT) as num_likes
      FROM
        questions
      LEFT OUTER JOIN
        question_likes on question_likes.question_id = questions.id
      WHERE
        questions.user_id = ?
    SQL

    data[0]["num_likes"] / data[0]["num_q"]
  end

end
