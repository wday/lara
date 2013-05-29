class AddRationaleToMultipleChoice < ActiveRecord::Migration
  def change
    add_column :embeddable_multiple_choices, :require_rationale, :boolean, :default => false
  end
end
