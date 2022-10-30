---
title: "Work"
menu:
  main:
    url: work/index.html
---
[Resume](./work/resume.html) [[pdf]](./work/amancevice.pdf)

## Kickstarter

| Apr 2021 — PRESENT | Brooklyn, New York
|:-|-:

> Lead planning and transition from cloud infrastructure from disparate
> CloudFormation templates (where existing) to Terraform monorepo.
>
> Lead planning and transition from Chef to custom AMIs using AWS EC2 Image Builder.
>
> Developed internal universal command line interface for executing developer
> tasks such as building, testing, and deploying.
>
> Set up custom Slack app for internal workflows and automated alerting.
> Introduced serverless patterns to the engineering team, including migrating a
> legacy system from AWS Elastic Container System (ECS) to AWS Lambda + API Gateway,
> leading to decreased latency and operational costs.

## CargoMetrics

| Apr 2013 — Mar 2021 | Boston, Massachusetts
|:-|-:

> Designed core components of CargoMetrics’ commodity trading system, including
> data models, command-line interfaces, dashboards, and cloud infrastructure.
>
> Helped the company transition from monolithic applications running on
> traditional infrastructure to microservices running in serverless or
> container-based environments.
>
> Migrated numerous legacy schedule-based systems to event-driven and resilient
> cloud processes, hardening reliability of cloud infrastructure and reducing
> the number of alarm states.
>
> Continuously iterated and improved upon design patterns that were adopted by
> the engineering team for infrastructure setup, CI/CD pipelines, and code
> design.

## DataXu

| Nov 2010 — Mar 2013 | Boston, Massachusetts
|:-|-:

> First hire for DataXu’s original Solutions Engineering team and helped craft
> the department’s role in the company.
>
> Developed toolkit for the growing Solutions Engineering team to use to
> maneuver through DataXu’s software stack, including the demo product for the
> flagship Ruby on Rails UI.
>
> Helped craft custom, rapid solutions and proof-of-concepts for DataXu’s
> programmatic ad-buying platform, including the initial proposal to integrate
> real-time video into the product.

## Vamosa

| Nov 2008 — Nov 2010 | Boston, Massachusetts
|:-|-:

> Designed, implemented, and executed the seamless transition of clients’
> legacy web content into new management systems using custom and reusable code
> components.
>
> Worked on site for clients in both a member of a small team and as a solo
> project executor to achieve success.

# Portfolio

## Brutalismbot
Web App | Ruby | NodeJS\
[GitHub](https://github.com/brutalismbot) | [Twitter](https://twitter.com/brutalismbot) | [brutalismbot.com](https://www.brutalismbot.com)

> Serverless app that mirrors posts from /r/brutalism to Twitter or Slack. The
> project is hosted on AWS using a completely serverless infrastructure.
> Alongside the core application is a static website hosted on S3 and
> distributed via CloudFront; support email address configured with SES, and
> application health monitoring via CloudWatch.

## Rum Runner
Build Tool | Ruby | Docker\
[GitHub](https://github.com/amancevice/rumrunner) | [RubyGems](https://rubygems.org/gems/rumrunner)

> DSL for writing declarative Docker-based workflows using Rake — Ruby’s
> popular make-like utility for working with build tasks. Users can install the
> gem from RubyGems, define their build, and use the rake CLI to build
> exportable artifacts inside the Docker build container or run arbitrary
> commands inside ephemeral containers at different stages of the build.

## Serverless PyPI
Terraform Module | Python | Terraform\
[GitHub](https://github.com/amancevice/terraform-aws-serverless-pypi) | [Terraform Registry](https://registry.terraform.io/modules/amancevice/serverless-pypi/aws)

> Terraform module for deploying a custom PyPI Index on AWS backed by S3. Users
> can store Python packages on S3 and retrieve them with pip over HTTP using
> API Gateway and a Lambda proxy function. An additional module is available to
> attach Cognito-based authentication to your index.

## SlackEnd
Express Middleware | NodeJS | Express\
[GitHub](https://github.com/amancevice/slackend) | [npm](https://www.npmjs.com/package/slackend)

> Middleware for Express to deploy an asynchronous REST API for developing
> Slack Apps. Requests from Slack are received, processed, and enhanced with
> routing instructions to be published to the notification/queuing service of
> your choice. Because SlackEnd is not opinionated about how messages are
> handled, extending Slack apps is easy and requires no code redeployment.

## Superset
Docker Image | Python | Docker\
[GitHub](https://github.com/amancevice/docker-superset) | [Docker Hub](https://hub.docker.com/r/amancevice/superset)

> The most-popular public Docker image for the Apache data visualization tool,
> Superset. In addition to tagged updates, weekly automated builds allow users
> to test features on the HEAD of the source repository.
