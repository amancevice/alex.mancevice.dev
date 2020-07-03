.env:
	cp $@.example $@

.terraform:
	terraform init

.terraform/terraform.zip: terraform.tf | .terraform
	terraform plan -out $@

.PHONY: apply clean clobber invalidation plan sync up

plan: .terraform/terraform.zip

apply: .terraform/terraform.zip
	terraform apply $<

clean:
	rm -rf .terraform/terraform.zip

clobber: clean
	rm -rf .terraform

invalidation:
	aws cloudfront create-invalidation \
	--distribution-id $$(terraform output cloudfront_distribution_id) \
	--paths '/*'

sync:
	aws s3 sync alexander s3://alexander.mancevice.dev/

up:
	open http://localhost:8000/
	ruby -run -e httpd alexander -p 8000
