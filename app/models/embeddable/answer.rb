module Embeddable::Answer
  def question_index
    if self.run && self.run.activity
      self.run.activity.questions.index(self.question) + 1
    else
      nil
    end
  end

  def prompt_no_itals
    parsed_prompt = Nokogiri::HTML::DocumentFragment.parse(prompt)
    itals = parsed_prompt.at_css "i"
    if itals
      itals.content = nil
    end
    parsed_prompt.to_html
  end

  def send_to_portal
    run.send_to_portal(self) if run
  end

  def to_json
    portal_hash.to_json
  end
end