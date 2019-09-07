ARG TERRAFORM_VERSION=latest

FROM hashicorp/terraform:${TERRAFORM_VERSION} AS build
WORKDIR /var/task/
COPY . .
RUN sha256sum alexander/* | sha256sum > alexander.sha256sum

FROM hashicorp/terraform:${TERRAFORM_VERSION} AS plan
WORKDIR /var/task/
COPY --from=build /var/task/ .
ARG AWS_ACCESS_KEY_ID
ARG AWS_DEFAULT_REGION=us-east-1
ARG AWS_SECRET_ACCESS_KEY
ARG TF_VAR_release
RUN apk add --no-cache python3 && pip3 install awscli
RUN terraform init
RUN terraform plan -out terraform.zip
CMD ["apply", "terraform.zip"]
