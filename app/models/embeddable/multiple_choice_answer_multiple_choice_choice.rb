class Embeddable::MultipleChoiceAnswerMultipleChoiceChoice < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :multiple_choice_answer
  belongs_to :multiple_choice_choice

end
