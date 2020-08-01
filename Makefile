.PHONY: plan apply sync cachebust clean clobber up

plan: .terraform/terraform.zip

apply: .terraform/terraform.zip
	terraform apply $<
	rm $<

cachebust: | .terraform
	aws cloudfront create-invalidation --paths '/*' --distribution-id $$(terraform output cloudfront_distribution_id)

clean:
	rm -rf .terraform/terraform.zip .terraform/outputs

clobber: clean
	rm -rf .terraform

up:
	@echo 'Starting server on http://localhost:8080/'
	ruby -run -e httpd www

sync: | .terraform
	aws s3 sync www s3://$$(terraform output bucket_name)/

.env:
	cp $@.example $@

.terraform:
	terraform init

.terraform/terraform.zip: *.tf | .terraform
	terraform fmt -check
	terraform plan -out $@
