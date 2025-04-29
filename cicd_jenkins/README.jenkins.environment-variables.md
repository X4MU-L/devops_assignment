# 6. Given a sample Jenkinsfile, identify and explain how environment variables and credentials should be managed securely.

When your application needs passwords or API keys, you don't want to write them directly in your code. Jenkins provides a secure vault where you can store these secrets, and your pipeline can access them when needed.

## Real-World Secure Jenkinsfile (Vault Integration)

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

### Vault Structure:

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

### Requirements for this to work:

- Install and configure the Jenkins HashiCorp Vault Plugin.

- Configure Jenkins with Vault server address, authentication (e.g., AppRole, JWT, etc.).

- Proper Vault policies to allow Jenkins to read only needed paths.

- Secrets structured inside Vault with a known path format.

## Summary

In high-security setups, using Jenkins + HashiCorp Vault integration ensures secrets are pulled live at build time, never hardcoded, masked in logs, and easy to rotate without modifying your Jenkinsfiles.
This is a best practice when you need to scale your security beyond basic static credentials.
