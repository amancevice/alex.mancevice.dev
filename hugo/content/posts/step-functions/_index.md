---
title: "Using Amazon Step Functions"
date: 2020-08-22T16:52:08-04:00
draft: false
toc: true
images:
tags:
  - AWS
  - StepFunctions
  - Serverless
---

Step Functions is an orchestration tool hosted on AWS for managing stateful workflows across distributed services. Additionally, Step Functions provides an excellent visual editor in the console where you can construct state machines and inspect the operations of individual executions. It may in fact be the best service console in the entire platform.

Amazon has also recently announced some [big improvements](https://aws.amazon.com/blogs/aws/aws-step-functions-adds-updates-to-choice-state-global-access-to-context-object-dynamic-timeouts-result-selection-and-intrinsic-functions-to-amazon-states-languages/) to the States Language (in particular, the `Choice` state’s features were greatly expanded), so if you haven’t explored Step Functions in a while, now is a great time to re-familiarize yourself with the tool.

In this document, I will explore some of the tricks and hidden features in Step Functions that have improved my understanding of the tool.

## Rescue Your Exceptions

Exception handling is one of Step Function’s greatest features. It feels extremely thought-out and is generally pretty intuitive.

You can configure a state to retry on a given exception with a maximum number of retries, a delay between retries, and even a backoff rate, which acts as a multiplier to the delay. For example, using a delay of 8 seconds with a backoff rate of 1.5 will result in successive retries with delays of 8 s, 12 s, 18 s, 27 s, and so on.

Amazon recommends at minimum adding Retry steps to tasks that handle AWS service events. Eg, for Lambda tasks:

```json
"Retry": [
  {
    "IntervalSeconds": 2,
    "MaxAttempts": 6,
    "BackoffRate": 2,
    "ErrorEquals": [
      "Lambda.ServiceException",
      "Lambda.AWSLambdaException",
      "Lambda.SdkClientException"
    ]
  }
]
```

While it may seem like a chore to add to all your task states, using the Retry/Catch functionality native to Step Functions will greatly improve their resiliancy.

In fact, it’s a good idea to familiarize yourself with the stated [Best Practices](https://docs.aws.amazon.com/step-functions/latest/dg/sfn-best-practices.html) in Amazon’s documentation while you add Retry/Catch features to your Step Functions.

## Stub New Projects

When beginning a new project in Step Functions, you may find it useful to start out by substituting `Pass` states everywhere you intend to eventually invoke a `Task`. This allows you to iterate quickly and visualize your state machine as you make changes.

![Stub new projects](/images/posts/step-functions/stub-new-projects.png)

### Interpolation with Pass States

While interpolation is not allowed in the Result field for task states, you can achieve the same effect using the always available Parameters field.

For example, this Pass state would be valid in Step Functions state language, but would not behave how you might expect:

```json
{
  "Type": "Pass",
  "End": true,
  "Result": {
    "Jazz.$": "$.Fizz"
  }
}
```

Instead of extracting the value from the input at path$.Fizz and injecting it into the Jazz field of the result, this state’s output would be the literal:

```json
{ "Jazz.$": "$.Fizz" }
```

Not very useful.

But if we use the Parameters field we can achieve the desired effect:

```json
{
  "Type": "Pass",
  "End": true,
  "Parameters": {
    "Jazz.$": "$.Fizz"
  }
}
```

This state will properly extract the desired value from the input, eg:

```json
{ "Fizz": "Buzz" } -> [ Pass State ] -> { "Jazz": "Buzz" }
```

Simple!

Using interpolation in this fashion, we can more closely mimic how the Task state might process the state.

---

## Namespace Your Inputs

Take full advantage of the path operators `InputPath`, `OutputPath`, and `ResultPath` in your state machines. While it might be tempting to configure the first state in your Step Function to ingest the execution input directly, you may discover that this technique hamstrings you down the road.

For example, an inexperienced developer may attempt to start an execution manually, leaving in the default `Comment` field that AWS automatically populates in the web console. What if the state receiving the input is incapable of handling an input with a `Comment` field? Better to configure the State Machine to expect input a level above the inputs to your tasks.

It would also be inadvisable to code particulars of the state machine into the tasks that are invoked by it. Each task should be decoupled from the implementation of the overall pipeline. Using the native path handling in state machines is a much better way of transporting state between tasks.

![Namespace your inputs](/images/posts/step-functions/namespace-your-inputs.png)

In this example, the raw input the the execution might be:

```json
{
  "Comment": "This is a valid comment",
  "Input-1": {
    "this": "will be the payload used by 'State 1'"
  }
}
```

The example above would extract the inner object from `$.Input-1` and attach the output of the state to `$.Output-1`.

Gaining a deep understanding of how inputs and outputs are handled in Step Functions is essential if you want to master the tool.

---

## Input Routing

One of the limitations of Step Functions is that partial executions of state machines are not supported out of the box — executions are processed from the top or not at all. For most state machines this isn’t a critical obstacle, especially if the state machine’s effects are idempotent.

But if a given state in your Step Function takes a particularly long time to execute or fails in a way that was not expected and not rescued, the value of being able to skip a section of the function becomes more apparent.

One method of achieving this is opening your state machine with a `Choice` state that is capable of routing the input to states downstream.

There isn’t a standard way of coding this, but my preferred technique is to start a state machine with a choice state that expects input of the format:

```json
{
  "StartAt": "Name of State",
  "Input": {
    "this": "object will be forwarded to the state at $.StartAt"
  }
}
```

I settled on this format because the `StartAt` key should be familiar to anyone who has worked with Step Functions. Choosing `Input` as the key for the payload to hand to the next state ought to be similarly self-explanatory.

Incidentally, this is a good example of how namespacing the inputs to your Step Functions can provide added value to your applications.

![Input routing](/images/posts/step-functions/input-routing.png)

```json
{
  "Comment": "Input Routing Example",
  "StartAt": "Route Input",
  "States": {
    "Route Input": {
      "Type": "Choice",
      "Default": "Step 1",
      "OutputPath": "$.Input",
      "Choices": [
        {
          "Variable": "$.StartAt",
          "StringEquals": "Step 2",
          "Next": "Step 2"
        },
        {
          "Variable": "$.StartAt",
          "StringEquals": "Step 3",
          "Next": "Step 3"
        }
      ]
    },
    "Step 1": { "Type": "Pass", "Next": "Step 2" },
    "Step 2": { "Type": "Pass", "Next": "Step 3" },
    "Step 3": { "Type": "Pass", "End": true }
  }
}
```

---

## Encapsulate Logic Across State Machines

If a workflow gets complex enough, or you find yourself replicating certain sections of your state machines across Step Functions, then you may find that splitting your workflows into multiple state machines is a great solution to manage this complexity.

Step Functions allows state machines to invoke each other both synchronously and asynchronously.

### Associate Executions

[Hidden deep](https://docs.aws.amazon.com/step-functions/latest/dg/concepts-nested-workflows.html) in the Step Functions documentation is a feature explaining how to start an execution from a state machine with a reference to the caller in the invocation.

In practice what this means is that when you inspect an execution on the web, the Step Functions console will display a hyperlink to the parent execution.

Pretty neat!

![Associate executions](/images/posts/step-functions/associate-executions.png)

To associate executions, add the magic key `AWS_STEP_FUNCTIONS_STARTED_BY_EXECUTION_ID` to your task input:

```json
{
  "Type": "Task",
  "Resource": "arn:aws:states:::states:startExecution.sync:2",
  "End":true,
  "Parameters":{
    "StateMachineArn":"arn:aws:states:us-west-2:123456789012:stateMachine:child",
    "Input": {
      "AWS_STEP_FUNCTIONS_STARTED_BY_EXECUTION_ID.$": "$$.Execution.Id",
      "NewStateInput": {
        "Fizz": "Buzz"
      }
    }
  }
}
```

The `$$.Execution.Id` is a reference to the execution context object, as indicated by the leading `$$`. prefix.

### Invoke State Machines Asynchronously

Let’s say you want to create a workflow that runs on a schedule, but does not always have work to do. In this case you might use a `Choice` state to route the state to the worker or to a simple `Success` state in the event there is no work to do.

Defining both routes in a single state machine makes it impossible to distinguish which executions resulted in a no-op from the executions that actually touched your data.

Instead, you could break the problem into two distinct state machines: one to handle the logic to determine if there is work to be done, and another to do the work.

![Invoke async](/images/posts/step-functions/invoke-async.png)

In this example it isn’t necessary for the first state machine to wait for the second to complete; invoking it asynchronously is perfectly reasonable. Use the Resource ARN `arn:aws:::states:startExecution` to start an execution asynchronously.

### Invoke State Machines Synchronously

An alternative use case might be one where you wish to isolate a state machine containing logic that can be shared across a group of Step Functions in the same logical domain.

For example, consider the case where you want to interact with a fussy remote API but don’t want to have to deal with the hassle of defining the states to interact with it in every state machine that consumes data from the API.

We can construct a generic state machine that accepts a query for the fussy remote API, submits it to the service, awaits the response, and finally persists the response to S3 and returns a presigned URL for consumers downstream (catching and retrying exceptions along the way, of course).

We will also add input routing as described above to help in dealing with any errors that might crop up.

![Invoke sync](/images/posts/step-functions/invoke-sync.png)

We can now construct other project-specific state machines that invoke this generic one synchronously in order to mask some of the complexities of the remote API.

As a bonus, by returning a presigned URL, we don’t have to worry about granting any special IAM permissions to the project-specific state machine in order to access to the S3 object where our data is stored!

Use the Resource ARN `arn:aws:states:::states:startExecution.sync`, or `arn:aws:states:::states:startExecution.sync:2` to invoke a state machine synchronously and process the resulting output downstream.

The difference between the two is that the output of the `.sync` flavor will be a JSON string, while `.sync:2` will return an actual object that can be manipulated in path processing.

---

Thats it! Thanks for reading, I hope you found some of it useful.
