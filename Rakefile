require "rake/clean"
CLEAN.include ".terraform/terraform.zip"
CLOBBER.include ".terraform"
task :default => %i[plan]

directory(".terraform") { sh "terraform init" }

".terraform/terraform.zip".tap do |planfile|
  file planfile => Dir["*.tf", "alexander/*"], order_only: ".terraform" do
    sh "terraform plan -out #{planfile}"
  end

  desc "Run terraform init"
  task :init => %w[.terraform]

  desc "Run terraform plan"
  task :plan => planfile

  desc "Run terraform apply"
  task :apply => planfile do
    sh "terraform apply #{planfile}"
  end
end

desc "Invalidate CloudFront cache"
task :invalidation => :init do
  sh <<~EOS
    aws cloudfront create-invalidation \
    --distribution-id $(terraform output cloudfront_distribution_id) \
    --paths '/*'
  EOS
end

desc "Sync local to S3"
task :sync => :init do
  sh "aws s3 sync alexander s3://$(terraform output bucket_name)/"
end

desc "Bring up local HTTP server"
task :up do
  sh "ruby -run -e httpd alexander -p 8000"
end
