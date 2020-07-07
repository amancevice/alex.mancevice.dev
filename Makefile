.terraform:
	terraform init

.terraform/terraform.zip: *.tf alexander/* | .terraform
	terraform plan -out $@

.PHONY: plan apply clean clobber invalidation sync up

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
