require_relative 'questions_db'
class QuestionFollow

  def self.followers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_follows ON users.id = question_follows.user_id
      WHERE
        question_id = ?
    SQL

    raise "Nothing found" if data.empty?
    data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_follows ON questions.id = question_follows.question_id
      WHERE
        question_follows.user_id = ?
    SQL

    raise "Nothing found" if data.empty?
    data.map{ |datum| Question.new(datum) }
  end

  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
      JOIN
        (
        SELECT
          question_id, COUNT(id) AS num_follows
        FROM
          question_follows
        GROUP BY
          question_id

        ) as most_followed ON most_followed.question_id = questions.id
      ORDER BY
        most_followed.num_follows  DESC
      LIMIT
        ?
    SQL

    raise "ERROR" if data.empty?
    data.map{ |datum| Question.new(datum) }
  end
end
