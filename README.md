# DevOps Final Assessment Questions

This assessment submission is part of the steps for the completion of the DevOps bootcamp with Developer Foundary.

## Table of Contents

1. [Ansible & Automation](ansible_and_automation/README.md#ansible--automation)
   - [Idempotency in Configuration Management](ansible_and_automation/README.idempotency.configuration.md#1-explain-the-concept-of-idempotency-in-configuration-management-why-is-it-important-and-how-does-the-ansibleposixsysctl-module-help-achieve-it-compared-to-using-ansiblebuiltincommand)
   - [Structuring Ansible Playbooks for Multi-tier Applications](ansible_and_automation/README.playbooks.muilti-teir-application.md#2-given-a-multi-tier-application-describe-how-you-would-structure-your-ansible-playbooks-and-roles-for-maximum-reusability-and-maintainability)
   - [Securely Managing Secrets in Ansible](ansible_and_automation/README.managing.secrets.md#3-write-an-ansible-playbook-snippet-that-securely-manages-secrets-and-avoids-exposing-sensitive-data-in-logs-or-output)
   - [Managing Different Environments with Ansible Inventories](ansible_and_automation/README.managing.inventories.md#4-how-would-you-use-ansible-inventories-to-manage-different-environments-eg-staging-vs-production-provide-an-example)
2. [CI/CD (Jenkins)](#cicd-jenkins)
   - [Jenkins Pipeline Stages for Containerized Applications](#5-describe-the-typical-stages-you-would-include-in-a-jenkins-pipeline-for-a-containerized-application-why-is-each-stage-important)
   - [Managing Environment Variables and Credentials in Jenkins](#6-given-a-sample-jenkinsfile-identify-and-explain-how-environment-variables-and-credentials-should-be-managed-securely)
   - [Benefits of Declarative Pipelines in Jenkins](#7-what-are-the-benefits-of-using-declarative-pipelines-in-jenkins-provide-a-simple-example)
3. [Infrastructure as Code (Terraform & Localstack)](#infrastructure-as-code-terraform--localstack)
   - [Terraform Commands and State File](#8-explain-the-purpose-of-terraform-init-plan-and-apply-what-is-the-significance-of-the-state-file)
   - [Localstack for Development and Testing](#9-how-does-localstack-help-in-local-development-and-testing-of-cloud-infrastructure-provide-a-scenario-where-it-would-be-especially-useful)
   - [Terraform S3 Bucket with IAM Restrictions](#10-write-a-terraform-configuration-snippet-to-provision-an-s3-bucket-and-restrict-its-access-to-a-specific-iam-user)
   - [Managing Terraform Modules for Large Projects](#11-describe-how-you-would-manage-terraform-modules-for-a-large-project-what-are-the-best-practices-for-module-versioning-and-reuse)
4. [Kubernetes & Orchestration](#kubernetes--orchestration)
   - [Kubernetes Resource Types Comparison](#12-explain-the-difference-between-kubernetes-deployments-statefulsets-and-daemonsets-when-would-you-use-each)
   - [Deploying Applications with Helm](#13-describe-the-process-of-deploying-an-application-using-helm-what-are-the-advantages-of-using-helm-charts)
   - [Injecting Secrets into Kubernetes Deployments](#14-how-would-you-securely-inject-secrets-into-a-kubernetes-deployment-provide-an-example-using-kubernetes-secrets)
   - [Horizontal Pod Autoscaling in Kubernetes](#15-given-a-scenario-where-you-need-to-scale-an-application-based-on-cpu-usage-explain-how-you-would-configure-horizontal-pod-autoscaling-in-kubernetes)

## CI/CD (Jenkins)

### 5. Describe the typical stages you would include in a Jenkins pipeline for a containerized application. Why is each stage important?

A typical Jenkins pipeline for a containerized application would include these essential stages:

1. Checkout (Source Code Checkout)

- _What happens_: Pulls the latest code from your source control (e.g., GitHub, GitLab, Bitbucket).

- _Why it's important_: We always want to build from the freshest, latest code. No outdated code, no surprises.

```groovy
stage('Checkout') {
  steps {
    git branch: 'main', url: 'https://github.com/myrepo/myapp.git'
  }
}
```

2. Unit Tests

- _What happens_: Runs unit tests (small tests that check individual functions/classes).

- _Why it's important_: Catches bugs early, before you waste time building or deploying broken software.

```groovy
stage('Unit Test') {
    steps {
            sh 'npm run test'
    }
}
```

3. Build

- _What happens_: Compiles or builds the application (e.g., Node.js npm build, Java mvn package, Go go build, etc.).

- _Why it's important_: Helps verify that the code is structurally correct and that no build-time errors exist before moving forward.

```groovy
stage('Build') {
    steps {
        sh 'npm install && npm run build'
    }
}
```

4. Build Docker Image

- _What happens_: Creates a Docker image from your application code (usually a Dockerfile).

- _Why it's important_: Packages our app and dependencies into a standardized, portable format. Essential for containerized deployment.

```groovy
stage('Docker Build') {
    steps {
        sh 'docker build -t myapp:${BUILD_NUMBER} .'
    }
}
```

5. Push Docker Image to Registry

_What happens_: Uploads the Docker image to a container registry (like Docker Hub, AWS ECR, GitHub Packages, etc.).

_Why it's important_: Our deployment environments (like Kubernetes) need a way to pull the built image.
No registry push = nothing to deploy!

```groovy
stage('Push to Registry') {
  steps {
    withDockerRegistry([credentialsId: 'dockerhub-creds', url: '']) {
      sh 'docker push myapp:${BUILD_NUMBER}'
    }
  }
}
```

6. Deployment

- _What happens_: Deploys the Docker image to an environment (could be a Kubernetes cluster, Docker Swarm, or even just a VM running Docker).

_Why it's important_: Verifies that the container actually runs correctly outside your local machine, usually in a "staging" environment before production.

```groovy
stage('Deploy to Staging') {
    steps {
        sh 'kubectl set image deployment/myapp-deployment myapp-container=myrepo/myapp:${BUILD_NUMBER}'
    }
}
```

7.  Integration or Smoke Tests

- _What happens_: After deploying to staging, run integration tests or basic "is-it-alive" checks.

_Why it's important_: Verifies that the app starts up properly and basic functionality works before promoting to production.

```groovy
stage('Smoke Tests') {
    steps {
        sh './scripts/smoke_tests.sh'
    }
}
```

---

### 6. Given a sample Jenkinsfile, identify and explain how environment variables and credentials should be managed securely.

When your application needs passwords or API keys, you don't want to write them directly in your code. Jenkins provides a secure vault where you can store these secrets, and your pipeline can access them when needed.

🏗 Real-World Secure Jenkinsfile (Vault Integration)

```groovy
pipeline {
  agent any

  environment {
       // Environment-specific variables
        DEPLOY_ENV = "${params.ENVIRONMENT}"
        // Credentials loaded from Jenkins credentials store
        AWS_CREDENTIALS = credentials('aws-access-key')
        // Database credentials bound to individual variables
        DB_CREDS = credentials('database-credentials')
        // IMAGE TAG
        IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
  }

  stages {
    stage('Checkout') {
        steps {
            checkout scm
            // Store the commit SHA for later use
            script {
                env.GIT_COMMIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                env.GIT_COMMIT_MSG = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
            }
        }
    }

    stage('Fetch Secrets from Vault') {
        steps {
            withVault([
                vaultSecrets: [
                    [path: 'secret/data/ci/dockerhub', secretValues: [
                    [envVar: 'DOCKER_USER', vaultKey: 'username'],
                    [envVar: 'DOCKER_PASS', vaultKey: 'password']
                    ]],
                    [path: 'secret/data/ci/api', secretValues: [
                    [envVar: 'API_TOKEN', vaultKey: 'token']
                    ]]
                ]
            ]) {
                echo "Vault secrets fetched securely."
            }
        }
    }

    stage('Test') {
        parallel {
            stage('Backend Tests') {
                steps {
                    dir('backend') {
                        // Adjust based on your backend tech stack
                        sh 'npm install && npm test'
                    }
                }
            }
            stage('Frontend Tests') {
                steps {
                    dir('frontend') {
                        sh 'npm install && npm run test'
                    }
                }
            }
            stage('Mail Service Tests') {
                steps {
                    dir('mail_service') {
                        sh 'pytest'
                    }
                }
            }
        }
    }

    stage('Build and Push Images') {

        //  agent {
        //     kubernetes {
        //         yaml """
        //             apiVersion: v1
        //             kind: Pod
        //             metadata:
        //               labels:
        //                 app: docker-build-agent
        //             spec:
        //               containers:
        //               - name: docker
        //                 image: docker:latest
        //                 command:
        //                 - cat
        //                 tty: true
        //                 volumeMounts:
        //                 - name: docker-socket
        //                   mountPath: /var/run/docker.sock
        //               volumes:
        //               - name: docker-socket
        //                 hostPath:
        //                   path: /var/run/docker.sock
        //         """
        //         defaultContainer 'docker'
        //     }
        // }
        // steps {
        //     withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials',
        //                                    usernameVariable: 'DOCKER_USERNAME',
        //                                    passwordVariable: 'DOCKER_PASSWORD')]) {
        //         sh """
        //             echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
        //             docker build -t ${REGISTRY}/backend:${IMAGE_TAG} ./backend
        //             docker tag ${REGISTRY}/backend:${IMAGE_TAG} ${REGISTRY}/backend:latest
        //             docker push ${REGISTRY}/backend:${IMAGE_TAG}
        //             docker push ${REGISTRY}/backend:latest
        //             docker build -t ${REGISTRY}/frontend:${IMAGE_TAG} ./frontend
        //             docker tag ${REGISTRY}/frontend:${IMAGE_TAG} ${REGISTRY}/frontend:latest
        //             docker push ${REGISTRY}/frontend:${IMAGE_TAG}
        //             docker push ${REGISTRY}/frontend:latest
        //             docker build -t ${REGISTRY}/mail_service:${IMAGE_TAG} ./mail_service
        //             docker tag ${REGISTRY}/mail_service:${IMAGE_TAG} ${REGISTRY}/mail_service:latest
        //             docker push ${REGISTRY}/mail_service:${IMAGE_TAG}
        //             docker push ${REGISTRY}/mail_service:latest
        //
        //             # Output the image details for logging
        //             echo "Built and pushed images with tag: ${IMAGE_TAG}"
        //             echo "Registry: ${REGISTRY}"
        //             echo "Git commit: ${GIT_COMMIT_SHORT}"
        //         """
        //     }
        // }

        // or
        parallel {
            stage('Backend Build/Push') {
                steps {
                    dir('backend') {
                        script {
                            docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                                def backendImage = docker.build("${REGISTRY}/backend:${IMAGE_TAG}")
                                backendImage.push()
                                // Also tag as latest
                                backendImage.push('latest')
                            }
                        }
                    }
                }
            }
            stage('Frontend Build/Push') {
                steps {
                    dir('frontend') {
                        script {
                            docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                                def frontendImage = docker.build("${REGISTRY}/frontend:${IMAGE_TAG}")
                                frontendImage.push()
                                // Also tag as latest
                                frontendImage.push('latest')
                            }
                        }
                    }
                }
            }
            stage('Mail Service Build/Push') {
                steps {
                    dir('mail_service') {
                        script {
                            docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                                def mailServiceImage = docker.build("${REGISTRY}/mail_service:${IMAGE_TAG}")
                                mailServiceImage.push()
                                // Also tag as latest
                                mailServiceImage.push('latest')
                            }
                        }
                    }
                }
            }
        }
        post {
            success {
                echo "Successfully built and pushed images with tag: ${IMAGE_TAG}"
            }
        }
    }

    stage('Deploy with Ansible') {
        agent {
            kubernetes {
                yaml """
                    apiVersion: v1
                    kind: Pod
                    metadata:
                    labels:
                        app: ansible-agent
                    spec:
                    containers:
                    - name: ansible
                        image: ansible/ansible-runner:latest
                        command:
                        - cat
                        tty: true
                        volumeMounts:
                        - name: ssh-key
                        mountPath: /keys
                        readOnly: true
                    volumes:
                    - name: ssh-key
                        secret:
                        secretName: ansible-ssh-key
                        defaultMode: 0400
                """
                defaultContainer 'ansible'
            }
        }

        steps {
            dir('ansible') {
                sh """
                    export ANSIBLE_HOST_KEY_CHECKING=False
                    ansible-playbook -i inventory.ini playbook.yml \
                    --private-key=/keys/ssh-private-key \
                    --extra-vars "backend_image=${REGISTRY}/backend:${IMAGE_TAG} \
                                frontend_image=${REGISTRY}/frontend:${IMAGE_TAG} \
                                mail_service_image=${REGISTRY}/mail_service:${IMAGE_TAG} \
                                build_number=${env.BUILD_NUMBER} \
                                git_commit=${env.GIT_COMMIT_SHORT}"
                """
            }
        }
}

        stage('Health Check') {
            steps {
                script {
                    // Wait for deployment to complete and services to start
                    sleep(30)

                    // Check application health endpoints
                    def backendHealth = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://your-app-url/api/health", returnStdout: true).trim()
                    def frontendHealth = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://your-app-url", returnStdout: true).trim()

                    if (backendHealth != "200" || frontendHealth != "200") {
                        error("Health check failed: Backend=${backendHealth}, Frontend=${frontendHealth}")
                    }
                }
            }
        }
    }

    post {
        success {
            // Update GitHub commit status
            sh "curl -H 'Authorization: token ${GITHUB_TOKEN}' -X POST -d '{\"state\": \"success\", \"context\": \"Jenkins CI/CD\", \"description\": \"Build ${BUILD_NUMBER} succeeded\", \"target_url\": \"${BUILD_URL}\"}' https://api.github.com/repos/yourorg/yourrepo/statuses/${GIT_COMMIT}"

            // Notify team of successful deployment
            slackSend(color: 'good', message: "Deployment successful: ${env.JOB_NAME} #${env.BUILD_NUMBER} - ${env.GIT_COMMIT_MSG} (${env.GIT_COMMIT_SHORT})")
        }
        failure {
            // Rollback on failure
            dir('ansible') {
                sh """
                    ansible-playbook -i inventory.ini rollback.yml \
                    --extra-vars "previous_build=${env.BUILD_NUMBER.toInteger() - 1}"
                """
            }

            // Update GitHub commit status
            sh "curl -H 'Authorization: token ${GITHUB_TOKEN}' -X POST -d '{\"state\": \"failure\", \"context\": \"Jenkins CI/CD\", \"description\": \"Build ${BUILD_NUMBER} failed\", \"target_url\": \"${BUILD_URL}\"}' https://api.github.com/repos/yourorg/yourrepo/statuses/${GIT_COMMIT}"

            // Notify team of deployment failure
            slackSend(color: 'danger', message: "Deployment failed: ${env.JOB_NAME} #${env.BUILD_NUMBER} - ${env.GIT_COMMIT_MSG} (${env.GIT_COMMIT_SHORT})")
        }
        always {
            // Clean workspace after build
            cleanWs()
        }
    }
}
```

Vault Structure:

```plaintext
secret/data/ci/dockerhub
    ├── username: mydockeruser
    └── password: mydockerpass

secret/data/ci/api
    └── token: supersecrettoken
```

Policies to Jenkins AppRole:

```hcl
path "secret/data/ci/dockerhub" {
  capabilities = ["read"]
}

path "secret/data/ci/api" {
  capabilities = ["read"]
}
```

Key security practices in this Jenkinsfile:

- **Jenkins Credentials Plugin**: Stores sensitive information outside the pipeline code

- **Credential Binding**: The credentials() function securely injects credentials into environment variables

- **withCredentials Block**: Limits credential availability to only the necessary steps

- **withVault block**: Pulls secrets live at runtime from HashiCorp Vault. Secrets never sit inside Jenkins.

- **Vault Paths**: Example: secret/data/ci/dockerhub holds DockerHub credentials; secret/data/ci/api holds API tokens.

- **Mapping Vault keys to env vars**: The secrets fetched (username, password, token) are mapped into environment variables (DOCKER_USER, DOCKER_PASS, API_TOKEN).

- **Secrets are ephemeral**: Secrets exist only inside the pipeline during execution. They are never stored permanently on the Jenkins controller or agents.

- **Secrets masked automatically**: If Vault and Jenkins are properly configured, all fetched secrets are masked from console output too.

- **Secrets rotated easily**: Since Vault manages secrets separately, you can rotate them without touching Jenkins.

#### Requirements for this to work:

- Install and configure the Jenkins HashiCorp Vault Plugin.

- Configure Jenkins with Vault server address, authentication (e.g., AppRole, JWT, etc.).

- Proper Vault policies to allow Jenkins to read only needed paths.

- Secrets structured inside Vault with a known path format.

#### Summary

In high-security setups, using Jenkins + HashiCorp Vault integration ensures secrets are pulled live at build time, never hardcoded, masked in logs, and easy to rotate without modifying your Jenkinsfiles.
This is a best practice when you need to scale your security beyond basic static credentials.

---

### 7. What are the benefits of using declarative pipelines in Jenkins? Provide a simple example.

Imagine giving directions to someone. You could tell them every turn to make (imperative), or you could just tell them the destination and let them figure out the best route (declarative). Declarative pipelines focus on what you want to achieve, not how to do it.

#### Declarative pipelines in Jenkins offer several significant benefits:

- _Simplified Syntax_: Provides a more structured, predictable format that is easier to read and maintain.

- _Built-in Validation_: The declarative syntax allows Jenkins to validate the pipeline structure before execution.

- _Pipeline Visualization:_ Declarative pipelines generate a visual representation in the Jenkins UI.

- _Integration with Blue Ocean_: Better support for the modern Jenkins Blue Ocean interface.

- _Reduced Boilerplate Code_: Many common patterns are built into the declarative syntax.

`agent any` → Run the pipeline on any available Jenkins agent.

`environment block` → Define environment variables globally for the pipeline.

`stages` → Logical breakdown of steps (Checkout, Build, Test, Deploy).

`when condition` → Only deploy if the build is from the main branch.

`post block `→ Cleanly handle success/failure notifications at the end.

Here's a simple example of a declarative pipeline:

```groovy
pipeline {
    agent any

    tools {
        maven 'Maven 3.8.4'
        jdk 'JDK 11'
    }

    stages {
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'mvn deploy'
            }
        }
    }

    post {
        failure {
            mail to: 'team@example.com',
                 subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
                 body: "The pipeline failed. Check console output at ${env.BUILD_URL}"
        }
    }
}

```

This example demonstrates the clarity of declarative pipelines with their distinct sections for agent, tools, stages, and post-actions. The when condition shows how you can declaratively control execution flow.

## Infrastructure as Code (Terraform & Localstack)

### 8. Explain the purpose of terraform init, plan, and apply. What is the significance of the state file?

When you're managing cloud infrastructure, you don't want to click around manually.
You want to define your infrastructure in code — that's where Terraform comes in.

But once you write that code... how does Terraform know what to do with it?
That's where commands like `terraform init`, `plan`, and `apply `— and the mysterious `terraform.tfstate` file — come into play.

Let's break everything down clearly, with examples!

#### `terraform init` — Getting Ready

Before you can do anything with Terraform, you have to run:

```bash
terraform init
```

What does it do?

Downloads the right providers — for example, if you want to create AWS resources, Terraform downloads the AWS provider plugin automatically.

Sets up backends — if you're storing your state remotely (e.g., in AWS S3), init configures that too.

Prepares the working directory — creating a hidden .terraform/ folder where it keeps internal stuff.

e.g

Suppose you have this very simple Terraform configuration file (`main.tf`):

```hcl
provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "my_bucket" {
    bucket = "my-terraform-demo-bucket"
}
```

Running `terraform init` will:

Download the AWS provider.

Set up your project so you can actually start working.

You must run init before anything else — think of it like "installing dependencies" when working on a software project.

#### `terraform plan` — Preview the Future

After initialization, you run:

```bash
terraform plan
```

This command does not change anything yet!
Instead, it shows you what Terraform would do if you applied the changes.

It compares:

- _What your code says you want_

- _What currently exists (based on the state file)_

- _What actions are needed to sync the two_

You get a nice color-coded output:

- _Green ➔ to create_

- _Yellow ➔ to update_

- _Red ➔ to destroy_

Example output

```bash
Plan: 1 to add, 0 to change, 0 to destroy.
```

It tells you exactly what it's planning to create.

`terraform plan` is your chance to catch mistakes before Terraform actually touches anything!

#### `terraform apply` — Make It Real

Once you're happy with the plan, you can move forward with:

```bash
terraform apply
```

Terraform will:

Prompt you to confirm (unless you use -auto-approve)

Create, update, or destroy resources based on the plan

Update the state file to reflect the new reality

Example workflow:

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

Here, you first save the plan to a file (tfplan), and then apply that exact plan later.
This is useful for auditing or approval processes — the plan you apply cannot differ from what was reviewed.

#### The Terraform State File (`terraform.tfstate`)

Terraform does not "ask AWS" (or any provider) every time it wants to know the state of your infrastructure, what you have.
Instead, it maintains its own state file — a snapshot of your infrastructure.

**Why the state file is critical:**

**Mapping**: It keeps track of what resources Terraform created (e.g., "this S3 bucket belongs to this resource block").

**Efficient Planning**: It speeds up terraform plan because it doesn’t need to query everything from scratch.

**Detecting Drift**: If something is changed outside Terraform, the state helps detect that the real infrastructure has "drifted" from the desired state.

> [! CAUTION]
> Sensitive Information Sometimes, the state contains secrets (like passwords or access keys), so it must be protected!

Example of a statefile

```json
{
  "resources": [
    {
      "type": "aws_s3_bucket",
      "name": "my_bucket",
      "instances": [
        {
          "attributes": {
            "bucket": "my-terraform-demo-bucket"
          }
        }
      ]
    }
  ]
}
```

### 9. How does Localstack help in local development and testing of cloud infrastructure? Provide a scenario where it would be especially useful.

LocalStack is a tool that mimics AWS cloud services locally — like S3, Lambda, DynamoDB, SQS, SNS, API Gateway, etc. — so you can develop and test cloud-based applications without needing an actual AWS account or paying for AWS resources during development.

#### How LocalStack helps in local development and testing:

- **Faster iteration**: You don’t wait for resources to be provisioned in real AWS.

- **Cost-effective**: No charges for spinning up services, storage, or invoking Lambdas.

- **Safe**: No risk of accidentally affecting production infrastructure.

- **CI/CD friendly**: LocalStack can run inside Docker containers, allowing you to test cloud deployments and behaviors - during automated tests without connecting to AWS.

- **Supports Infrastructure as Code (IaC)**: You can test Terraform, CloudFormation, or CDK deployments fully locally.

- **Simulates cloud failures**: You can test things like network interruptions, throttling, or permission errors locally.

#### A particularly useful scenario:

Consider developing a serverless application that uses AWS Lambda, API Gateway, DynamoDB, and S3. During development:

1. **Without Localstack**: Each code change requires deploying to AWS, waiting for the deployment to complete, and incurring costs for each resource. Testing error conditions often means manually creating failure scenarios in production-like environments.
2. **With Localstack**: Developers can:

- Deploy the entire stack locally in seconds
- Make code changes and immediately see results
- Test error handling by easily simulating service failures
- Work offline without internet connectivity
- Integrate with CI/CD for automated testing without cloud costs
- Debug serverless functions with local debugging tools

This is especially valuable for serverless applications where the integration between services is critical to the application's functionality but traditionally difficult to test locally.

### 10. Write a Terraform configuration snippet to provision an S3 bucket and restrict its access to a specific IAM user.

When you're starting with Terraform, it’s tempting to just throw resources directly into a `.tf` file: a user here, a bucket there, a policy here. But as your infrastructure grows, so does the chaos. That's where modules come in. My best approach, I always take the `"hard-painful-easy"` approach

Today, let's look at a practical example: provisioning an IAM user who can access a private S3 bucket — and how using modules makes our life significantly better... as matter of fact if i be very honest, i am aswering this question with a module i had once written

I'll also walk us through a real-world example you might recognize if you've worked with AWS.

I have created an [s3 module](terraform/modules/storage) and [iam module](terraform/modules/iam)

```hcl
module "storage" {
  source = "./terraform/modules/storage"

  bucket_name_prefix = "my-app-prod-bucket"
  resource_suffix    = "prod01"
  environment        = "prod"
  purpose            = "AppBucket"
  enable_versioning  = true

  lifecycle_rules = [
    {
      id                         = "expire-logs"
      status                     = "Enabled"
      prefix                     = "logs/"
      expiration_days            = 60
      noncurrent_expiration_days = 180
    }
  ]

  tags = {
    Project = "MyApp"
    Owner   = "PlatformTeam"
  }
}

module "iam_user" {
  source = "../../modules/iam"

  iam_user_name_prefix   = "appuser"
  iam_policy_name_prefix = "apppolicy"
  resource_suffix        = "prod01"
  environment            = "prod"
  purpose                = "AppUserForProd"
  policy_description     = "Policy granting access to specific S3 bucket"
  create_access_key      = true

  policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "s3:ListBucket"
      ]
      Resource = module.storage.bucket_arn
    },
    {
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ]
      Resource = "${module.storage.bucket_arn}/*"
    }
  ]

  tags = {
    Project = "MyApp"
    Owner   = "PlatformTeam"
  }
}

```

We provision the bucket first (doesn't really matter the other in the file, terraform will provision each according to dependency), then reference its ARN when building IAM policies.

`module.storage.bucket_arn` gives us the ARN of the bucket, and `"${module.s3_bucket.bucket_arn}/*"` targets all objects inside.

By parameterizing Action, Resource, and Effect, our IAM module can handle any permission case you throw at it and can be can be used for any other resource.

#### Why Using Modules Here Is the Right Move

1. **Reusability**: You can provision many buckets and users by simply reusing your modules with different variables.

2. **Maintainability**: If AWS changes something (say, adds a new field to S3 configuration), you only update the module once, not in every project.

3. **Separation of Concerns**: 
    - IAM logic stays in iam/
    - S3 logic stays in storage/ This keeps teams focused and code clean.

4. **Security**: We’re enforcing least privilege with tightly scoped policies at module level — no accidentally wide-open S3 access.

5. **Scalability**: Tomorrow, we could wrap these modules with environment layers (dev, staging, prod) using workspaces or any other tool.

#### Final Thought

Infrastructure isn't just about writing Terraform. It's about designing it like real software.
When you use modules, you treat your cloud resources like reusable components, not one-off scripts.
And that is the foundation of scalable DevOps practices.

### 11. Describe how you would manage Terraform modules for a large project. What are the best practices for module versioning and reuse?

When you're working on a large project — dozens of resources, many environments (dev, staging, prod), multiple teams — modules become _`critical`_ for:

- **Consistency** across resources

- **Reusability** (no copying and pasting code)

- **Ease of Maintenance** (fix one place, propagate changes)

- **Separation of Responsibility** between teams

Here’s **how I would structure and manage Terraform modules in a large project**:

1. **Organize Modules Cleanly**

    Split modules by resource type or logical purpose, like:

    ```plaintext
    /modules
    /vpc
    /ec2_instance
    /rds_database
    /s3_bucket
    /iam_user
    /cloudfront
    ```

    Each module should do one thing well (single responsibility).
    Large modules (like a VPC module) can even have submodules inside if needed.

2. **Use Clear Input/Output Interfaces**

    Each module should define:

    - Variables clearly (`variables.tf`)

    - Outputs clearly (`outputs.tf`)

    - Default sensible values where possible (but allow override)

    e.g from our previous [s3](terraform/modules/storage) and [iam](terraform/modules/iam) modules

    ```hcl
    ## modules/iam/variables.tf
    variable "create_access_key" {
    description = "Whether to create an access key for the IAM user"
    type        = bool
    default     = true
    }

    ## modules/storage/variables.tf
    variable "lifecycle_rules" {
    description = "List of lifecycle rules"
    type = list(object({
        id                         = string
        status                     = string
        prefix                     = string
        expiration_days            = number
        noncurrent_expiration_days = number
    }))
    default = []
    }
    ```

    Good modules should **not assume** things — they should be **predictable** and **configurable**.

3. **Use Semantic Versioning for Modules (`SemVer`)**

    Versioning of modules can be done as follows:

    - `v1.0.0`: Initial stable version

    - `v1.1.0`: Backwards-compatible improvements

    - `v2.0.0`: Breaking changes

    When you release modules (especially across multiple teams), use Git tags:

    ```bash
    git tag v1.0.0
    git push origin v1.0.0
    ```

    Then in Terraform you pin specific versions:

    ```hcl
    module "vpc" {
    source  = "git::https://github.com/org/terraform-aws-vpc.git?ref=v1.0.0"
    # ...
    }
    ```

    local resource can as well be used for better environment management and development source switching

    ```hcl
    locals {
    # Set to true for local development, false for production
    is_local_dev = true
    
    # Dynamically set the source based on environment
    # for monorepo
    vpc_module_source = local.is_local_dev ? "./modules/storage" : "git::https://github.com/yourname/terraform-modules.git//terraform/modules/storage?ref=v1.0.0"

    # Dynamically set the source based on environment
    # for remote repo
    vpc_module_source = local.is_local_dev ? "./modules/storage" : "git::https://github.com/yourname/terraform-modules.git/s3-storage?ref=v1.0.0"
    }

    module "vpc" {
    source = local.vpc_module_source
    # Module inputs here
    }
    ```

4. **Manage Environments Separately**

    Instead of trying to complicate modules with environment logic, keep modules generic, and manage environments via your Terraform code:

    ```plaintext
    /terraform
    /dev
        main.tf
        variables.tf
    /staging
        main.tf
        variables.tf
    /prod
        main.tf
        variables.tf
    ```

    Each environment calls the modules with different inputs.

#### Summary

Managing Terraform projects effectively requires a structured approach to ensure scalability, maintainability, and collaboration across teams. Here are the key practices:

1. **Organize Small Modules**

    - **Why**: Smaller modules are simpler to understand, easier to reuse, and reduce duplication.

    - **How**: Create modules for specific resources or logical purposes (e.g., VPC, S3, IAM). Each module should have a single responsibility.

2. **Use Semantic Versioning (SemVer)**

    - **Why**: Semantic versioning ensures safe upgrades and controlled releases.

    - **How**: Use Git tags (e.g., `v1.0.0`, `v1.1.0`, `v2.0.0`) to version modules. Pin module versions in Terraform configurations to avoid unexpected changes.

3. **Use Remote Module Sources**

    - **Why**: Remote sources (e.g., Git, S3, Terraform Registry) make it easy to distribute and reuse modules across teams and projects.

    - **How**: Reference modules using URLs or registry paths, and version them for consistency.

4. **Define Clear Inputs and Outputs**

    - **Why**: Predictable modules with well-defined inputs and outputs are easier to use and integrate.

    - **How**: Use `variables.tf` for inputs and `outputs.tf` for outputs. Provide sensible defaults and clear documentation.

5. **Validate and Test Modules**

    - **Why**: Validation and testing ensure safety and prevent errors in production.

    - **How**: Use tools like `terraform validate` and `terratest` to test modules. Validate configurations before applying changes.

6. **Separate Environments Cleanly**

    - **Why**: Separating environments (e.g., dev, staging, prod) avoids spaghetti code and ensures flexibility.

    - **How**: Use separate directories for each environment, with environment-specific variables and configurations. Reference shared modules with environment-specific inputs.

By following these practices, you can build Terraform projects that are scalable, maintainable, and easy to collaborate on, while minimizing risks and ensuring consistency across environments.

## Kubernetes & Orchestration

### 12. Explain the difference between Kubernetes Deployments, StatefulSets, and DaemonSets. When would you use each?

Kubernetes offers several resource types for deploying applications, each designed for specific use cases:

#### Deployments

Deployments are _"Self-healing stateless application manager"_, they can as well be seen as a Load-balanced web servers behind an autoscaler, why `"web Servers"`?, Typically web servers are stateless, and we want to use deployments for only stateless applications - Focused on high availability, scalability, and statelessness. Any replica can serve any request.

- Creates a ReplicaSet to maintain the desired number of Pods.

- Replaces unhealthy Pods automatically — no identity needed.

- Supports rolling updates and rollbacks

- Pods receive random names and IPs when scaled/restarted

- Ideal for applications that scale horizontally.

Example: Scaling a frontend from 3 Pods to 10 in response to traffic., It can be likened to **dynamic compute workers** — any replica can handle any user request.

e.g of yaml file for a Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
```

#### StatefulSet

StatefulSet are like _"Controller for ordered, stateful applications with stable storage"_, Each node has a stable network identity and persistent storage. Order matters during creation, scaling, and updates. Often used for Databases (MySQL, PostgreSQL, MongoDB), Distributed systems (Kafka, ZooKeeper, Elasticsearch), applications requiring stable hostnames, systems needing ordered scaling operations.

- Assigns stable network names (e.g., `mysql-0`, `mysql-1`).

- Binds each Pod to a dedicated `PersistentVolumeClaim` (`PVC`).

- Manages ordered deployment, scaling, and updates.

Example: Scaling a Kafka cluster where `broker-1` cannot just be replaced randomly.

e.g of yaml file for a StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: "postgres"
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:14
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

#### DaemonSet

Think opf DaemonSet like _"Cluster-wide service deployment manager"_, it is a system agents installed on every server. It ensures every machine has a necessary background service running, like a metrics collector or a storage agent. It is often used for Monitoring agents (Prometheus Node Exporter), Log collectors (Fluentd, Logstash), Network plugins (Calico, Weave), Storage daemons (Ceph), Node-level services.

- Schedules exactly one `Pod` per `node`.

- Extends automatically when new `nodes` join the `cluster` (Can be configured to run only on nodes matching certain criteria).

- Ensures critical services (log shippers, monitoring agents, node security daemons) run everywhere.

Example: Deploying a Prometheus node exporter on every server.

Think of it like mandatory system agents installed on every machine for consistency.

e.g of yaml file for a DaemonSet

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluentd:v1.14
```

### 13. Describe the process of deploying an application using Helm. What are the advantages of using Helm charts?

Helm is the package manager for Kubernetes.
It simplifies deploying applications by bundling Kubernetes manifests into versioned, reusable packages called charts.

Deployment Process with Helm

1. **Install Helm**
    Install the Helm CLI on your machine (if not already):

    ```bash
    brew install helm  # macOS
    sudo apt install helm  # Ubuntu
    ```

2. **Add a Helm Repository (or create a custom chart)**

    A repository is like a package index (e.g., Artifact Hub, Bitnami charts):

    ```bash
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    ```

3. **Install a Chart**

    Use Helm to install a chart into your Kubernetes cluster:

    ```bash
    helm install my-app bitnami/nginx --namespace prod --create-namespace
    ```

    - `my-app` is the release name.
    - `bitnami/nginx` is the chart being installed.

    - `--namespace prod` deploys it into a Kubernetes namespace.

4. **Customize Values**

    To override default chart settings, create a values.yaml file:

    ```yaml
    replicaCount: 3
    service:
    type: LoadBalancer
    ```

    Then install with your custom values:

    ```bash
    helm install my-app bitnami/nginx -f values.yaml
    ```

5. **Upgrade / Rollback**

    Helm tracks revisions automatically:

    ```bash
    helm upgrade my-app bitnami/nginx -f new-values.yaml
    helm rollback my-app 1  # Roll back to revision 1
    ```

6. **Uninstall (Cleanup)**

    To remove the deployment:

    ```bash
    helm uninstall my-app
    ```

#### Advantages of Helm Charts:

- **Templating**: Charts use Go templating to generate Kubernetes manifests, allowing dynamic configuration.

- **Versioning**: Track different versions of your application deployments.

- **Release Management**: Easily upgrade, rollback, or uninstall applications.

- **Reusability**: Share configurations across deployments and environments.

- **Dependency Management**: Automatically install and manage dependencies between charts.

- **Hooks**: Execute tasks at specific points in the release lifecycle.

- **Testing**: Validate charts before deployment with built-in testing capabilities.

- **Community**: Leverage community-maintained charts for common applications.

Helm significantly reduces the complexity of Kubernetes deployments, especially for multi-component applications, while providing tools for managing the entire application lifecycle.

---

### 14. How would you securely inject secrets into a Kubernetes deployment? Provide an example using Kubernetes Secrets.

Managing secrets in Kubernetes isn’t just about `"storing a password"` — it’s about protecting your application, your cluster, and ultimately your company from critical security breaches.

In this piece, I’ll start simple, then progressively expand into how Kubernetes handles secrets internally, how encryption works, and how to secure them properly using best practices.

Let’s dive in.

#### Step 1: Creating a Kubernetes Secret

**a) Imperatively (One-liner via kubectl)**

You can create a secret imperatively using the kubectl create secret command:

```bash
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=SuperSecret123
```

This will immediately create a Secret object inside Kubernetes, containing the username and password.

**b) Declaratively (YAML Manifests)**

It's better to manage secrets as code using YAML files:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
data:
  username: YWRtaW4=   # "admin" in base64
  password: U3VwZXJTZWNyZXQxMjM=   # "SuperSecret123" in base64
```

**Why Base64?**

Kubernetes Secrets must be valid and safe to transport over the network and store in JSON or YAML.
Base64 ensures the data doesn't break YAML syntax, introduce invalid characters, or become unreadable across systems.

> [!CAUTION]
> Base64 encoding is NOT encryption.
> It’s just encoding. Anyone can decode it trivially.

#### Step 2: How Kubernetes Internally Manages Secrets

When you create a Secret:

It’s sent to the Kubernetes API Server.

The API Server persists it into etcd, the cluster database.

By default, these secrets are only base64-encoded, not encrypted at rest — meaning if someone gets access to etcd, they can read your secrets easily.

**Problem:**

This makes it critical to encrypt your secrets at rest inside etcd.

#### Step 3: Enabling Encryption at Rest (via EncryptionConfiguration)

You can tell Kubernetes API Server to encrypt Secrets before saving them into etcd by providing an EncryptionConfiguration file.

Example configuration:

```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - kms:   # First try an external KMS provider (like AWS KMS)
          name: myKmsProvider
          endpoint: unix:///tmp/kms.socket
      - aesgcm:   # Fallback to a local symmetric key (AES-GCM)
          keys:
            - name: key1
              secret: pFq3kFJodLRQk3JKe/b5kj2kNjY4e09qRbRQzk7uO9I=  # Base64-encoded AES key
      - identity: {}   # Final fallback: no encryption (only for dev/test!)
```

**Flow:**

- Kubernetes tries encrypting Secrets using KMS first.

- If KMS fails, it uses local AES key encryption (AES-GCM).

- If even AES fails, it falls back to identity (no encryption).

**How AES-GCM Keys Work**

- AES keys are symmetric:
    The same key is used to both encrypt and decrypt.

- The Kubernetes API Server encrypts Secrets using only the first key (e.g., key1).

- It can decrypt Secrets with any key listed in the config.
    (This allows you to rotate keys over time without downtime.)

To explain further, when the api server wants to encrypt a key, it uses the first key in the AES-GCM key config, but when it wants to decrypts it tries each keys in the config till it hits a key that is able to decrypt the encrypted data that it wants to decrypt. The reason for this is for key rotation. Normally when you rotate keys, say every 4-months, usually by moving the original first key to second key, then add a new key..., new data will be encrypted with the new key, but old data will still be encrypted with the old key.

**Key rotation best practice:**
Add key2, make it the first key, remove key1 later once everything is re-encrypted.

**What About the AES Key?**: 
pFq3kFJodLRQk3JKe/b5kj2kNjY4e09qRbRQzk7uO9I=

- It’s a sensitive base64-encoded 256-bit AES key.

- We will never commit this key into Git.

- Store securely (e.g., Vault, AWS Secrets Manager, SSM Parameter Store).

- Ideally, fetch it dynamically (e.g., at bootstrap time via Ansible/Puppet/Chef).

**Example with Ansible:**

- At bootstrap time, your playbook might:

- Fetch the AES key securely.

- Render the EncryptionConfiguration.yaml.

- Start the API server with it mounted.

#### Step 4: How API Server Actually Encrypts Secrets

When the API Server receives a new Secret:

- It base64-decodes the data (plain text now).

- It encrypts the plaintext using the configured key (KMS or AES).

- It stores the ciphertext into etcd.

When reading a Secret:

- It decrypts the stored ciphertext.

- Returns base64-encoded plaintext to the caller (like a Pod or another API client).

The resource (pod) does NOT need the AES key or KMS key!
It trusts the Kubernetes API Server to decrypt for it.

#### Step 5: Controlling Who Can Access Secrets (RBAC)

Secrets are extremely sensitive.
You must control which pods, services, and users who can read them.

Example Role + RoleBinding to restrict Secret access:

```yaml
# Role allowing reading only secrets
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: prod
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
```

```yaml
# Bind a service account to the role
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: prod
  name: read-secrets
subjects:
- kind: ServiceAccount
  name: app-service-account
roleRef:
  kind: Role
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

Now only the app-service-account can get and list secrets in the prod namespace.

To ensure robust security for sensitive data, it is essential to adopt best practices for secret management. Utilize a reliable secret management solution, such as Vault or AWS KMS, to securely store and manage secrets. Always enable encryption at rest to protect secrets stored in systems like etcd. Implement the Principle of Least Privilege by restricting RBAC access to only those who truly need it. Use network policies to limit pod-to-pod access to secrets, reducing the risk of unauthorized exposure. Regularly audit access to secrets to maintain visibility into who accessed sensitive data and why. Additionally, rotate secrets frequently to minimize the impact of potential leaks. Finally, never log secrets; instead, mask or avoid exposing sensitive environment variables in logs to prevent accidental disclosure.

#### Final Thoughts

Kubernetes makes it easy to work with secrets — but securing them properly takes careful planning:

Encrypt secrets at rest.

Store encryption keys securely.

Limit access tightly via RBAC.

Monitor and rotate secrets regularly.

If you build your secrets management like this from the beginning, you'll sleep much better at night.

### 15. Given a scenario where you need to scale an application based on CPU usage, explain how you would configure Horizontal Pod Autoscaling in Kubernetes

In real-world production environments, most applications/infrastructure rarely experience a constant, predictable workload.

Some days they might sit idle.

Other times they might be flooded with user traffic.

How can your Kubernetes cluster automatically adapt?

The answer is Horizontal Pod Autoscaling (HPA).

In this guide, I'll try to explain:

- Why CPU-based scaling matters

- What requests and limits truly mean

- How the HPA works internally

- How Metrics are collected and used

- Step-by-step setup of an **HPA**

- Best practices you should know


#### Understanding Kubernetes Resource Requests and Limits

Before we can even think about scaling, we must first understand how Kubernetes handles resources.

Inside your Deployment (or StatefulSet, DaemonSet, etc.), we define resource requests and limits for each container, often times, we don't know the use of these - that used to be me:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

Let’s break this down carefully:

| Field |Meaning |
|:----- |:--------- |
| **requests.cpu: 100m**|"This container needs at least 100 millicores (0.1 CPU) to operate normally." |
| **requests.memory: 128Mi** |"This container needs at least 128MiB RAM." |
| **limits.cpu: 500m** | "This container is allowed to consume up to 500 millicores." |
| **limits.memory: 512Mi** |"This container can use up to 512MiB RAM maximum." |

#### Why Are Requests and Limits Important?

- **Kubernetes Scheduler uses requests**:
    When scheduling Pods to Nodes, Kubernetes reserves the requested resources on the Node.

    Without requests, Kubernetes assumes 0 resource need.

    The Pod might be scheduled onto an already busy Node.

    Requests = baseline guarantee.

- **Kubernetes enforces limits**
    If your Pod tries to consume more than the limit:

    For CPU: It gets throttled (slowed down).

    For memory: It gets killed if it exceeds the memory limit.

#### How Does HPA Use Requests?

This is **super important**:

HPA doesn't care about limits at all.

It only looks at CPU usage compared to the request.

e.g:

Suppose we have in a configuration:

- requests.cpu: 100m

- Actual CPU usage: 80m

- Then, utilization = (80m / 100m) × 100% = 80%

Here’s what happens behind the scenes:

1. Kubernetes runs a controller called HorizontalPodAutoscaler controller.

2. The controller periodically polls the Metrics API.

3. It gathers CPU (and optionally memory) utilization of all pods of a target deployment.

4. It calculates the average utilization across all pods.

5. It compares that against your configured target utilization.

6. Using a formula, it decides whether to scale up or scale down:

The formula is approximately:

**desiredReplicas** = **currentReplicas** × ( **current CPU utilization** / **target CPU utilization** )

If current utilization > target → scale up
If current utilization < target → scale down

#### Metrics Server: The Backbone of HPA

Kubernetes does not natively know how much CPU or memory pods are using.

It relies on a component called Metrics Server.

**Metrics Server**:

- Scrapes resource usage data from the Kubelet on each Node.

- Aggregates CPU and memory stats.

- Provides an API (/apis/metrics.k8s.io/) that HPA queries.

> [!IMPORTANT]
> If you don’t have Metrics Server installed and running, HPA won’t work!

You can install Metrics Server using Helm:

```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm install metrics-server metrics-server/metrics-server
```

Or apply a raw manifest:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

#### How to Configure Horizontal Pod Autoscaling (HPA)

Let’s build it properly.

1. Create a Deployment with CPU Requests

    First, define your app Deployment with requests set:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    name: my-app
    spec:
    replicas: 2
    selector:
        matchLabels:
        app: my-app
    template:
        metadata:
        labels:
            app: my-app
        spec:
        containers:
        - name: my-app
            image: my-app:latest
            resources:
            requests:
                cpu: 100m
                memory: 128Mi
            limits:
                cpu: 500m
                memory: 512Mi
    ```

   **Why 100m CPU request?**

    - It gives HPA a baseline to measure.

    - 50% usage = using 50m CPU.

2. Create a HorizontalPodAutoscaler (HPA)

    We can imperatively create it for testing:

    ```bash
    kubectl autoscale deployment my-app --cpu-percent=50 --min=2 --max=10
    ```

    Or — better — declaratively create it for production:

    ```yaml
    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
    name: my-app-hpa
    spec:
    scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: my-app
    minReplicas: 2
    maxReplicas: 10
    metrics:
    - type: Resource
        resource:
        name: cpu
        target:
            type: Utilization
            averageUtilization: 50
    ```

    **This configuration tells Kubernetes:**

    - Keep between 2 and 10 replicas.

    - Scale up or down to maintain ~50% CPU usage based on requests.

SO how does this all come together:

- Let's say we have 4 pods running.

- And CPU usage goes up to 90% (compared to 100m request).

- And from our HPA configuration our target is 50%.

HPA will calculate:

**desiredReplicas** = **4** × ( **90** / **50** ) = **7.2**

HPA will round up to 8 pods.

More pods → workload spread better → less CPU pressure.

#### Things to Watch Out For

- **No requests set?** HPA won't work properly — CPU utilization will show as 0% or unstable.

- Metrics Server must be installed and healthy.

- Pod startup times matter: If your app is slow to start, aggressive scaling can backfire.

- Memory-based HPA is possible too, but trickier (memory doesn't scale down easily like CPU).

- **Scaling cooldown** exists — Kubernetes doesn't scale every second, usually checks every 15–30 seconds.

#### Conclusion

The Horizontal Pod Autoscaler is one of the most powerful, important, and misunderstood features of Kubernetes.

When you deeply understand:

- how requests and limits work,

- how Metrics Server powers HPA,

- how HPA formula decides scaling,

you become a Kubernetes engineer who can truly build reliable, scalable cloud-native applications.

Scaling is not magic — it's math, metrics, and engineering.