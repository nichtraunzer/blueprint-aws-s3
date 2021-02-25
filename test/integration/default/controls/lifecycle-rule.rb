require_relative '../../default/libraries/terraform_data.rb'
require_relative '../../default/libraries/fixture_data.rb'
require_relative '../../default/libraries/aws.rb'

tfo_symbolized = input("output_module_blueprint_aws_s3")
tfo = JSON.parse(JSON.generate(tfo_symbolized), {symbolize_names: false})

control 'lifecycle-rule' do
  impact 1.0
  title  "Test Suite: 'lifecycle-rule'"
  desc   "This test suite asserts the correct functionality of the blueprint under test with required inputs only."

  tfo.each { |tfoelement|
    name = tfoelement['inputs2outputs'].first['name']
    id   = tfoelement['inputs2outputs'].first['id']
    f    = tfoelement['inputs2outputs'].first

    lifecycle_id = name + '-' + id + '-' + tfoelement['inputs2outputs'].first['lifecycle_rule_expiration_days'] + 'days-expiration'

    s3 = Aws::S3::Client.new()
    #s3_versioning=s3.get_bucket_versioning({ bucket: name + '-' + id })
    s3_lifecycle=s3.get_bucket_lifecycle({ bucket: name + '-' + id })
    describe aws_s3_bucket(bucket_name: name + '-' + id)  do
      before do
        skip if tfoelement['inputs2outputs'].first['lifecycle_rule_enabled'] == false
      end
      # context "versioning" do
      #   it { expect(s3_versioning.status).to eq "Suspended" }
      # end
      context "lifecycle id" do
        it { expect(s3_lifecycle.rules[0].id).to eq lifecycle_id }
      end
      context "lifecycle status" do
        it { expect(s3_lifecycle.rules[0].status).to eq "Enabled" }
      end
      context "lifecycle expiration days" do
        it { expect(s3_lifecycle.rules[0].expiration.days.to_i ).to eq f['lifecycle_rule_expiration_days'].to_i }
      end
      context "lifecycle noncurrent version expiration days" do
        it { expect(s3_lifecycle.rules[0].noncurrent_version_expiration.noncurrent_days.to_i ).to eq f['lifecycle_rule_noncurrent_version_expiration'].to_i }
      end
    end
  }
end
