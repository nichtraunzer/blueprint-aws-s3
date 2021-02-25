require_relative '../../default/libraries/terraform_data.rb'
require_relative '../../default/libraries/fixture_data.rb'
require_relative '../../default/libraries/aws.rb'

t    = SpecHelper::TerraformData.new
id   = t['id']
name = t['name']
tags = { :Name => name + '-' + id }

f = SpecHelper::FixtureData.new('bucket-policy').for_module(name)

control 'bucket-policy' do
  impact 1.0
  title  "Test Suite: 'bucket-policy'"
  desc   "This test suite asserts the correct functionality of the blueprint under test for a specific AWS S3 bucket policy."
  tag    name

  bucket_name = name + '-' + id
  describe aws_s3_bucket(bucket_name: bucket_name) do
    it                        { should exist }
    it                        { should_not be_public }
    its('bucket_acl.count')   { should eq 1 }
    it { should have_default_encryption_enabled }

    its('bucket_policy')      { should_not be_empty }
    its('bucket_policy.to_s') { should match /DenyIPCondition/ }
    its('bucket_policy.to_s') { should match /denyGetPut/ }
    its('bucket_policy')      { should cmp [
      OpenStruct.new(
        :sid       => "DenyIPCondition",
        :effect    => "Deny",
        :principal => { "AWS"=>"*" },
        :action    => "s3:*",
        :resource  => "arn:aws:s3:::#{bucket_name}/*",
        :condition => {
          "IpAddress" => {
            "aws:SourceIp" => "192.168.0.1/32"
          }
        }
      ),
      OpenStruct.new(
        :sid       => "denyGetPut",
        :effect    => "Deny",
        :principal => { "AWS"=>"*" },
        :action    => [
          "s3:PutObject",
          "s3:GetObject"
        ],
        :resource  => [
          "arn:aws:s3:::#{bucket_name}/*",
          "arn:aws:s3:::#{bucket_name}"
        ]
      )
    ]}
  end

end
