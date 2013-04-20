require 'spec_helper'

describe Run do
  let (:activity) { FactoryGirl.create(:activity) }
  let (:run) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r
  }
  let (:user) { FactoryGirl.create(:user) }

  describe 'validation' do
    it 'ensures session keys are 16 characters' do
      run.key = 'short'
      run.should_not be_valid
      run.key = 'thiskeyistoolongtobevalid'
      run.should_not be_valid
      run.key = '1234567890123456'
      run.should be_valid
    end

    it 'ensures session keys only have letters and numbers' do
      run.key = 'ABCDEabcde123456'
      run.should be_valid
      run.key = 'ABCD/abcd-12345;'
      run.should_not be_valid
      run.key = 'abcd ABCD_1234--'
      run.should_not be_valid
    end
  end

  describe '#session_guid' do
    it 'generates different hashes for each run' do
      first_guid = run.session_guid
      second_guid = run.session_guid

      first_guid.should_not === second_guid
    end

    it 'generates different hashes with a user than without' do
      first_guid = run.session_guid
      with_user_guid = run.session_guid(user)

      with_user_guid.should_not === first_guid
    end

  end

  describe '#check_key' do
    it 'creates a key for an object where key is nil' do
      run.key = nil
      run.key.should be_nil
      run.should be_valid # Validation triggers the key generation
      run.key.should_not be_nil
      run.should be_valid
    end
  end

  describe '#to_json' do
    it 'contains the proper keys and values' do
      json_blob = run.to_json(:methods => [:last_page, :storage_keys])
      json_blob.should match /activity_id/
      json_blob.should match /last_page/
      json_blob.should match /storage_keys/
      json_blob.should match /"key":"#{run.key}",/
      json_blob.should match /run_count/
      # {
      # activity_id: 1,
      # last_page: null,
      # storage_keys: []
      # key: "be19b7a04a2ea471",
      # run_count: null,
      # }
    end
  end
end