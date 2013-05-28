class CreateEmbeddableMultipleChoiceAnswerMultipleChoiceChoices < ActiveRecord::Migration
  def change
    rename_table :mc_answer_choices, :embeddable_multiple_choice_answer_multiple_choice_choices
    rename_column :embeddable_multiple_choice_answer_multiple_choice_choices, :answer_id, :multiple_choice_answer_id
    rename_column :embeddable_multiple_choice_answer_multiple_choice_choices, :choice_id, :multiple_choice_choice_id
    add_column :embeddable_multiple_choice_answer_multiple_choice_choices, :rationale, :string, :default => nil
  end
end
