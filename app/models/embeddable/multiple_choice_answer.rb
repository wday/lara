module Embeddable
  class MultipleChoiceAnswer < ActiveRecord::Base
    attr_accessible :answers, :run, :question

    belongs_to :question,
      :class_name  => 'Embeddable::MultipleChoice',
      :foreign_key => 'multiple_choice_id'

    belongs_to :run

    has_many :multiple_choice_answer_multiple_choice_choices,
      :dependent => :destroy, :class_name => 'Embeddable::MultipleChoiceAnswerMultipleChoiceChoice'
    has_many :answers, :through => :multiple_choice_answer_multiple_choice_choices,
      :source => :multiple_choice_choice

    scope :by_question, lambda { |q|
      {:conditions => { :multiple_choice_id => q.id}}
    }

    scope :by_run, lambda { |r|
      {:conditions => { :run_id => r.id }}
    }

    delegate :name,                :to  => :question
    delegate :prompt,              :to  => :question
    delegate :choices,             :to  => :question
    delegate :enable_check_answer, :to  => :question
    delegate :multi_answer,        :to  => :question
    delegate :require_rationale,   :to  => :question

    after_update :send_to_portal

    def question_index
      if self.run && self.run.activity
        self.run.activity.questions.index(self.question) + 1
      else
        nil
      end
    end

    # render the text of the answers
    def answer_texts
      self.answers.map { |a| a.choice }
    end

    def portal_hash
      {
        "type"          => "multiple_choice",
        "question_id"   => question.id.to_s,
        "answer_ids"    => answers.map { |a| a.id.to_s },
        "answer_texts"  => answer_texts
      }
    end

    def send_to_portal
      run.send_to_portal(self) if run
    end

    def to_json
      portal_hash.to_json
    end

    # Expects a parameters hash. Normalizes to allow update_attributes.
    def update_from_form_params(params)
      if params[:answers].kind_of?(Array)
        params[:answers] = params[:answers].map { |a| Embeddable::MultipleChoiceChoice.find(a) }
      else
        params[:answers] = [Embeddable::MultipleChoiceChoice.find(params[:answers])]
      end
      return self.update_attributes(params)
    end
  end

end