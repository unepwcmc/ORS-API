require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  before do
    @questionnaire = create_questionnaire
    @root_section = create_section(@questionnaire)
  end

  describe :answers do
    before do
      @question = create_question(@root_section, answer_type_type: 'NumericAnswer')
      @user1 = FactoryGirl.create(:user)
      @answer1 = FactoryGirl.create(:answer, question: @question, user: @user1)
      FactoryGirl.create(:answer_part, answer: @answer1)
      @user2 = FactoryGirl.create(:user)
      @answer2 = FactoryGirl.create(:answer, question: @question, user: @user2)
      FactoryGirl.create(:answer_part, answer: @answer2)
      @question_from_view = Test::Question.find(@question.id)
    end
    it "should have answers" do
      assert @question_from_view.answers.count == 2
    end
  end
  describe :looping_contexts do
    before do
      @loop_item_type = FactoryGirl.create(:loop_item_type)
      create_loop_item(@loop_item_type)
      create_loop_item(@loop_item_type)
      @looping_section = create_subsection(@root_section, {section_type: 0, loop_item_type: @loop_item_type})
      @question = create_question(@looping_section, answer_type_type: 'NumericAnswer')
      @question_from_view = Question.find(@question.id)
    end
    it "should have looping contexts" do
      assert @question_from_view.looping_contexts.count == 2
    end
  end

end
