require 'test_helper'

class LoopingContextTest < ActiveSupport::TestCase
  before do
    @questionnaire = create_questionnaire
    @root_section = create_section(@questionnaire)
    @loop_item_type = FactoryGirl.create(:loop_item_type)
    @looping_section = create_subsection(@root_section, {section_type: 0, loop_item_type: @loop_item_type})
    @loop_item1 = create_loop_item(@loop_item_type)
    @loop_item2 = create_loop_item(@loop_item_type)
    @question = create_question(@looping_section, answer_type_type: 'NumericAnswer')
    @question_from_view = Question.find(@question.id)
  end

  describe :answers do
    before do
      @user1 = FactoryGirl.create(:user)
      @answer1 = FactoryGirl.create(:answer, question: @question, user: @user1, looping_identifier: @loop_item1.id)
      FactoryGirl.create(:answer_part, answer: @answer1)
      @user2 = FactoryGirl.create(:user)
      @answer2 = FactoryGirl.create(:answer, question: @question, user: @user2, looping_identifier: @loop_item1.id)
      FactoryGirl.create(:answer_part, answer: @answer2)
      @looping_context1 = @question_from_view.looping_contexts.find_by_looping_identifier(@loop_item1.id)
      @looping_context2 = @question_from_view.looping_contexts.find_by_looping_identifier(@loop_item2.id)
    end
    it "should have answers for looping_context1" do
      assert @looping_context1.answers.count == 2
    end
    it "should not have answers for looping_context2" do
      assert @looping_context2.answers.count == 0
    end
  end
end
