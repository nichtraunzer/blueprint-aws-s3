require_relative '../libraries/terraform_data.rb'
require_relative '../libraries/fixture_data.rb'
require_relative '../libraries/aws.rb'

tfo_symbolized = input("output_module_blueprint_aws_s3")
tfo = JSON.parse(JSON.generate(tfo_symbolized), {symbolize_names: false})

# t    = SpecHelper::TerraformData.new
# id   = t['id']
# name = t['name']
# tags = { :Name => name + '-' + id }

# f = SpecHelper::FixtureData.new.for_module(name)

control 'default' do
  impact 1.0
  title  "Test Suite: 'default'"
  desc   "This test suite asserts the correct functionality of the blueprint under test with required inputs only."
  tag    tfo.first['inputs2outputs'].first['name']

  tfo.each { |tfoelement|
    name = tfoelement['inputs2outputs'].first['name']
    id   = tfoelement['inputs2outputs'].first['id']

    describe aws_s3_bucket(bucket_name: name + '-' + id) do
      it                      { should exist }
      it                      { should_not be_public }
      its('bucket_acl.count') { should eq 1 } # Independently of the settings, count is always 1.
      it { should have_default_encryption_enabled }
    end

    describe aws_s3_bucket(bucket_name: name + '-' + id) do
      before do
        skip if tfoelement['inputs2outputs'].first['use_bucket_policy'] == false
      end
      its('bucket_policy')    { should_not be_empty }
    end

    s3 = Aws::S3::Client.new()
    s3_versioning = s3.get_bucket_versioning({ bucket: name + '-' + id })

    if (tfoelement['inputs2outputs'].first['bucket_versioning'] == true) then
      expected_versioning_result = "Enabled"
    else
      expected_versioning_result = "Suspended"
    end
    describe aws_s3_bucket(bucket_name: name + '-' + id) do
      context "versioning" do
        it { expect(s3_versioning.status).to eq expected_versioning_result }
      end
    end
  }
end
