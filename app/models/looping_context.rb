class LoopingContext < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_questions_looping_contexts_view
  self.primary_key = :id

  def answers
    Answer.where(question_id: question_id, looping_identifier: looping_identifier)
  end
end
