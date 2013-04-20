require 'spec_helper'

describe RunsController do
  render_views
  let (:activity) { FactoryGirl.create(:activity) }
  let (:run) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r.save
    r
  }

  describe 'routing' do
    it 'recognizes and generates #show' do
      {:get => 'activities/3/runs/foobarbaz1234567'}.should route_to(:controller => 'runs', :action => 'show', :activity_id => "3", :id => 'foobarbaz1234567')
    end

    it 'does not route without activity ID' do
      begin
        get :show
      rescue ActionController::RoutingError
      end
    end

    it 'requires 16 character IDs' do
      begin
        get :show, :id => 'short', :activity_id => activity.id
        throw 'Should not be able to route with id "short"'
      rescue ActionController::RoutingError
      end
    end
  end

  describe '#index' do
    it 'creates a new object and redirects to #show' do
      existing_responses = Run.count
      get :index, :activity_id => activity.id
      assigns(:run).should_not be_nil
      assigns(:run).activity.should === activity
      response.should redirect_to :action => 'show', :activity_id => activity.id, :id => assigns(:run).key
    end
  end

  describe '#show' do
    context 'with valid ID' do
      it 'returns a JSON object with that ID' do
        get :show, :id => run.key, :activity_id => activity.id
        response.code.should == '200'
        # TODO: what should the body include?
        response.body.should match "multiple_choice_answers"
        response.body.should match "open_response_answers"
      end
    end

    context 'with new ID' do
      it 'creates a new object with that key and returns that object' do
        existing_responses = Run.count
        get :show, :id => 'thisisanewrespon', :activity_id => activity.id
        response.code.should == '200'
        # TODO: Check that the response body includes the new key
        Run.count.should == existing_responses+1
      end
    end
  end
end