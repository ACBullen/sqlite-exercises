require_relative 'questions_db'
class QuestionLikes

  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      WHERE
        id IN (
          SELECT
            user_id
          FROM
            question_likes
          WHERE
            question_id = ?
        )

    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(id) as num_likes
      FROM
        question_likes
      WHERE
        question_id = ?
      GROUP BY
        question_id
    SQL

    return 0 if data.empty?
    data[0]['num_likes']
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_likes on question_likes.question_id = questions.id
      WHERE
        question_likes.user_id = ?
    SQL

    raise "This guy doesn't like anything (how sad...)." if data.empty?
    data.map{ |datum| Question.new(datum) }
  end

  def self.most_liked_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
      JOIN
        question_likes ON questions.id = question_likes.question_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(question_likes.user_id) DESC
      LIMIT
        ?
    SQL
    raise "Nobody likes anything D:" if data.empty?
    data.map { |datum| Question.new(datum) }
  end


end
