require 'test_helper'

class QuestionTest < ActiveSupport::TestCase

  describe :answers do
    before do
      @questionnaire = create_questionnaire
      @root_section = create_section(@questionnaire)
    end

    describe "when regular section" do
      before do
        @question = create_question(@root_section, 'NumericAnswer')
        @user1 = FactoryGirl.create(:user)
        @answer1 = FactoryGirl.create(:answer, question: @question, user: @user1)
        FactoryGirl.create(:answer_part, answer: @answer1)
        @user2 = FactoryGirl.create(:user)
        @answer2 = FactoryGirl.create(:answer, question: @question, user: @user2)
        FactoryGirl.create(:answer_part, answer: @answer2)
        @question_from_view = Question.find(@question.id)
      end
      it "should have answers" do
        assert @question_from_view.answers.count == 2
      end

    end
    describe "when looping section" do

    end
  end

end
