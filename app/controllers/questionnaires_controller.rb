class QuestionnairesController < ApplicationController

  def index
  end

  def show
    @questionnaire = Questionnaire.find(params[:id])
  end

end
