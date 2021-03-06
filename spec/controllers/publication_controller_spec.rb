require 'spec_helper'
describe PublicationsController do
  let(:act) { FactoryGirl.create(:public_activity) }
  let(:private_act) { FactoryGirl.create(:activity)}
  let(:ar)  { FactoryGirl.create(:run, :activity_id => act.id) }
  let(:page) { act.pages.create!(:name => "Page 1", :text => "This is the main activity text.") }
  let(:sequence) { FactoryGirl.create(:sequence) }

  before(:each) do
    @user ||= FactoryGirl.create(:admin)
    sign_in @user
  end

  describe 'routing' do
    it 'recognizes and generates #show_status' do
      {:get => "/publications/show_status/LightweigthActivity/3"}.
        should route_to({
          :controller       => 'publications', 
          :action           => 'show_status',
          :publishable_type => 'LightweigthActivity', 
          :publishable_id   => "3"
      })
    end
  end

  describe "#add_portal" do
    let(:act_one) do
      LightweightActivity.create!(:name => 'Activity One',
                                  :description => 'Activity One Description',
                                  :publication_status => 'public')
    end
    let(:good_body) { "{\"type\":\"Activity\",\"name\":\"Activity One\",\"description\":\"Activity One Description\",\"url\":\"http://test.host/activities/#{act_one.id}\",\"create_url\":\"http://test.host/activities/#{act_one.id}\",\"sections\":[{\"name\":\"Activity One Section\",\"pages\":[]}]}" }
    let(:publishing_url) { "http://foo.bar/publish/v2/blarg"}
    let(:url) { "http://foo.bar/"}
    let(:mock_portal) { mock(:publishing_url => publishing_url, :url => url) }
    let(:good_request) {{
      :body => "{\"type\":\"Activity\",\"name\":\"Activity One\",\"description\":\"Activity One Description\",\"url\":\"http://test.host/activities/#{act_one.id}\",\"create_url\":\"http://test.host/activities/#{act_one.id}\",\"sections\":[{\"name\":\"Activity One Section\",\"pages\":[]}]}",
      :headers => {'Authorization'=>'Bearer', 'Content-Type'=>'application/json'}
    }}
    let(:good_response)   { {:status => 201, :body => "", :headers => {} }}
    let(:portal_response) { good_response }
    before(:each) do
     # @url = controller.portal_url
     # stub_request(:post, @url)
     controller.stub!(:find_portal).and_return mock_portal
      stub_request(:post, publishing_url).
        with(good_request).
        to_return(portal_response)
    end

    it "should have proper routing" do
      {:get => "/publications/add/LightweightActivity/1"}.
        should route_to({
          :controller       => 'publications', 
          :action           => 'add_portal',
          :publishable_type => 'LightweightActivity', 
          :publishable_id   => "1"
      })
    end

    it "should call 'publish!' on the activity" do
      get :add_portal, { :publishable_id => act_one.id, :publishable_type => "LightweightActivity" }
      act_one.publication_status.should == 'public'
    end

    it "should attempt to publish to the correct portal endpoint" do
      pending "New portal configurations, more testing here"
      @url.should == "#{ENV['CONCORD_PORTAL_URL']}/external_activities/publish/v2"
    end

    it "should attempt to publish to the portal" do
      get :publish, { :publishable_id => act_one.id, :publishable_type => "LightweightActivity" }
    end

    it 'creates a new PortalPublication record' do
      old_publication_count = act_one.portal_publications.length
      get :add_portal, { :publishable_id => act_one.id, :publishable_type => "LightweightActivity" }
      act_one.reload.portal_publications.length.should == old_publication_count + 1
    end
  end
end
