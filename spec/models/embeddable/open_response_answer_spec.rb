require 'spec_helper'

describe Embeddable::OpenResponseAnswer do
  before(:each) do
    @answer = Embeddable::OpenResponseAnswer.create({
      :answer_text          => "the answer"
    })
  end

  describe "model associations" do

    it "should belong to an open response" do
      question = Embeddable::OpenResponse.create()
      @answer.question = question
      @answer.save
      @answer.reload.question.should == question
      question.reload.answers.should include @answer
    end

    it "should belong to a run" do
      run = Run.create()
      @answer.run = run
      @answer.save
      @answer.reload.run.should == run
      run.reload.open_response_answers.should include @answer
    end
  end
end