# Project Initialization from Template

When creating a new project from this template, you should initialize the project to use your own naming conventions. Run the `init-project.sh` script in the root directory:

```
./init-project.sh
```

You will be prompted to enter:
- **groupId** (e.g., `com.example`)
- **artifactId** (e.g., `my-project`)
- **base package** (e.g., `com.example.myproject`)

The script will:
- Update the Maven `groupId` and `artifactId` in all module `pom.xml` files (`cdk`, `lambda`, `lambda-st`).
- Replace all occurrences of the default package name (`matty`) in Java, XML, and properties files with your chosen base package.
- Move Java source files from the default package directory to your new package directory structure.

This ensures your project uses your own naming and package conventions throughout all modules.

## Example: Acme Corp Order Service

Suppose your company is **Acme Corp** and your project is called **order-service**. When you run `./init-project.sh`, enter:

- **groupId**: `com.acme`
- **artifactId**: `order-service`
- **base package**: `com.acme.orderservice`

After initialization, your project will have:

- All Maven modules (`cdk`, `lambda`, `lambda-st`) with `pom.xml` updated to:
  ```xml
  <groupId>com.acme</groupId>
  <artifactId>order-service</artifactId>
  ```
- All Java source files moved to:
  ```
  cdk/src/main/java/com/acme/orderservice/...
  lambda/src/main/java/com/acme/orderservice/...
  lambda-st/src/main/java/com/acme/orderservice/...
  ```
- All package declarations in `.java` files updated to:
  ```java
  package com.acme.orderservice;
  ```

This ensures your project uses your company’s namespace and project name everywhere, ready for your organization’s standards.


# Credit: This template is based on work by Adam Bien (https://github.com/adambien)
# MicroProfile with Quarkus as AWS Lambda Function deployed with Cloud Development Kit (CDK) v2 for Java

A lean starting point for building, testing and deploying Quarkus MicroProfile applications deployed as AWS Lambda behind API Gateway.
The business logic, as well as, the Infrastructure as Code deployment are implemented with Java.

# TL;DR

A Quarkus MicroProfile application:

```java

@Path("hello")
@ApplicationScoped
public class GreetingResource {

    @Inject
    Greeter greeter;

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        return this.greeter.greetings();
    }

    @POST
    @Consumes(MediaType.TEXT_PLAIN)
    public void hello(String message) {
        this.greeter.greetings(message);
    }
}
```
...with an additional dependency / [extension](https://quarkus.io/guides/amazon-lambda-http) for AWS REST APIs Gateway:

```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-amazon-lambda-rest</artifactId>
</dependency>
```

or HTTP APIs Gateway (default configuration):

```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-amazon-lambda-http</artifactId>
</dependency>
```

...deployed with AWS Cloud Development Kit:

```java

Function createFunction(String functionName,String functionHandler, 
    Map<String,String> configuration, int memory, int maximumConcurrentExecution, int timeout) {

        return Function.Builder.create(this, functionName)
                .runtime(Runtime.JAVA_21)
                .code(Code.fromAsset("../lambda/target/function.zip"))
                .handler(functionHandler)
                .memorySize(memory)
                .functionName(functionName)
                .environment(configuration)
                .timeout(Duration.seconds(timeout))
                .reservedConcurrentExecutions(maximumConcurrentExecution)
                .build();
    }
```
You choose between HTTP APIs gateway and REST APIs gateway with the `httpAPIGatewayIntegration` variable:

``` java
public class CDKApp {
    public static void main(final String[] args) {

            var app = new App();
            var appName = "quarkus-apigateway-lambda-cdk";
            Tags.of(app).add("project", "MicroProfile with Quarkus on AWS Lambda");
            Tags.of(app).add("environment","development");
            Tags.of(app).add("application", appName);

            var httpAPIGatewayIntegration = true;
            new CDKStack(app, appName, true);
            app.synth();
        }
    }
}
```

## Prerequisites

## Java

1. Java / openJDK is installed
2. [Maven](https://maven.apache.org/) is installed

## AWS 

Same installation as [aws-cdk-plain](https://github.com/AdamBien/aws-cdk-plain):

0. For max convenience use the [`default` profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html). A profile named `default` doesn't have to be specificed with the `--profile` flag or configured in CDK applications.
1. Install [AWS CDK CLI](https://docs.aws.amazon.com/cdk/latest/guide/getting_started.html)
2. [`cdk boostrap --profile YOUR_AWS_PROFILE`](https://docs.aws.amazon.com/cdk/latest/guide/bootstrapping.html)

This template ships with AWS HTTP APIs Gateway. REST APIs Gateway is also supported. You can switch between both by using the corresponding extension (see [Choosing between HTTP APIs and REST APIs](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vs-rest.html). 

Private APIs are only supported by [REST API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-private-apis.html).

You can also build AWS Lambda `function.zip` and executable Quarkus JAR by extracting the extension into a Maven profile. Checkout: [https://adambien.blog/roller/abien/entry/hybrid_microprofile_deployments_with_quarkus](https://adambien.blog/roller/abien/entry/hybrid_microprofile_deployments_with_quarkus).


# in action

## full build

Build the Quarkus project `lambda` and deploy it with `cdk` as AWS Lambda:

```
cd lambda
./build-and-deploy-auto.sh
```

## continuous and accelerated deployment

To continuously deploy the AWS Lambda at any changes, perform: 

```
cd cdk
cdk watch
```

Now on every: `mvn package` in `lambda` directory / project the JAX-RS application is re-deployed automatically.

## local deployment

You can run the `lambda` project as regular Quarkus application with:

`mvn compile quarkus:dev`

The application is available under: `http://localhost:8080/hello`