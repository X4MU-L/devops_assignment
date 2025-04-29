# 7. What are the benefits of using declarative pipelines in Jenkins? Provide a simple example.

Imagine giving directions to someone. You could tell them every turn to make (imperative), or you could just tell them the destination and let them figure out the best route (declarative). Declarative pipelines focus on what you want to achieve, not how to do it.

## Declarative pipelines in Jenkins offer several significant benefits:

- _Simplified Syntax_: Provides a more structured, predictable format that is easier to read and maintain.

- _Built-in Validation_: The declarative syntax allows Jenkins to validate the pipeline structure before execution.

- _Pipeline Visualization:_ Declarative pipelines generate a visual representation in the Jenkins UI.

- _Integration with Blue Ocean_: Better support for the modern Jenkins Blue Ocean interface.

- _Reduced Boilerplate Code_: Many common patterns are built into the declarative syntax.

`agent any` → Run the pipeline on any available Jenkins agent.

`environment block` → Define environment variables globally for the pipeline.

`stages` → Logical breakdown of steps (Checkout, Build, Test, Deploy).

`when condition` → Only deploy if the build is from the main branch.

`post block` → Cleanly handle success/failure notifications at the end.

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
