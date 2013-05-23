class CreateEmbeddableMultipleChoiceAnswerMultipleChoiceChoices < ActiveRecord::Migration
  def change
    # TODO: reuse existing mc_answer_choices table
    create_table :embeddable_multiple_choice_answer_multiple_choice_choices do |t|

      t.timestamps
    end
  end
end
