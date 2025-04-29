# 5. Describe the typical stages you would include in a Jenkins pipeline for a containerized application. Why is each stage important?

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

7. Integration or Smoke Tests

    - _What happens_: After deploying to staging, run integration tests or basic "is-it-alive" checks.

    _Why it's important_: Verifies that the app starts up properly and basic functionality works before promoting to production.

    ```groovy
    stage('Smoke Tests') {
        steps {
            sh './scripts/smoke_tests.sh'
        }
    }
    ```
