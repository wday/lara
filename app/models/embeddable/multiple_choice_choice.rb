module Embeddable
  class MultipleChoiceChoice < ActiveRecord::Base
    attr_accessible :multiple_choice, :choice, :prompt, :is_correct

    belongs_to :multiple_choice, :class_name => "Embeddable::MultipleChoice"

    has_many :multiple_choice_answer_multiple_choice_choices, :dependent => :destroy,
      :class_name => "Embeddable::MultipleChoiceAnswerMultipleChoiceChoice"
    has_many :answers, :through => :multiple_choice_answer_multiple_choice_choices,
      :source => :multiple_choice_answer, :class_name => 'Embeddable::MultipleChoiceAnswer'

    def to_hash
      hash = {
        'choice' => is_correct,
      }
      if prompt && multiple_choice.custom
        hash['prompt'] = prompt
      end
      hash
    end

    def to_json
      MultiJson.dump(self.to_hash)
    end

    def page
      if multiple_choice && !multiple_choice.interactive_pages.empty?
        return multiple_choice.interactive_pages.last
      else
        return nil
      end
    end

    def duplicate
      return Embeddable::MultipleChoiceChoice.new( choice: self.choice, prompt: self.prompt, is_correct: self.is_correct )
    end
  end
end
