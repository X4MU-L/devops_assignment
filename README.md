# DevOps Final Assessment Questions

This assessment submission is part of the steps for the completion of the DevOps bootcamp with Developer Foundary.

## Table of Contents

1. [Ansible & Automation](ansible_and_automation/README.md#ansible--automation)
   - [Idempotency in Configuration Management](ansible_and_automation/README.idempotency.configuration.md#1-explain-the-concept-of-idempotency-in-configuration-management-why-is-it-important-and-how-does-the-ansibleposixsysctl-module-help-achieve-it-compared-to-using-ansiblebuiltincommand)
   - [Structuring Ansible Playbooks for Multi-tier Applications](ansible_and_automation/README.playbooks.muilti-teir-application.md#2-given-a-multi-tier-application-describe-how-you-would-structure-your-ansible-playbooks-and-roles-for-maximum-reusability-and-maintainability)
   - [Securely Managing Secrets in Ansible](ansible_and_automation/README.managing.secrets.md#3-write-an-ansible-playbook-snippet-that-securely-manages-secrets-and-avoids-exposing-sensitive-data-in-logs-or-output)
   - [Managing Different Environments with Ansible Inventories](ansible_and_automation/README.managing.inventories.md#4-how-would-you-use-ansible-inventories-to-manage-different-environments-eg-staging-vs-production-provide-an-example)
2. [CI/CD (Jenkins)](cicd_jenkins/README.md#cicd-jenkins)
   - [Jenkins Pipeline Stages for Containerized Applications](cicd_jenkins/README.pipeline.containerization.md#5-describe-the-typical-stages-you-would-include-in-a-jenkins-pipeline-for-a-containerized-application-why-is-each-stage-important)
   - [Managing Environment Variables and Credentials in Jenkins](cicd_jenkins/README.jenkins.environment-variables.md#6-given-a-sample-jenkinsfile-identify-and-explain-how-environment-variables-and-credentials-should-be-managed-securely)
   - [Benefits of Declarative Pipelines in Jenkins](cicd_jenkins/README.declarative.pipeline.md#7-what-are-the-benefits-of-using-declarative-pipelines-in-jenkins-provide-a-simple-example)
3. [Infrastructure as Code (Terraform & Localstack)](infrastructure-as-code/README.md#infrastructure-as-code-terraform--localstack)
   - [Terraform Commands and State File](infrastructure-as-code/README.commands.statefile.md#8-explain-the-purpose-of-terraform-init-plan-and-apply-what-is-the-significance-of-the-state-file)
   - [Localstack for Development and Testing](infrastructure-as-code/README.localstack.md#9-how-does-localstack-help-in-local-development-and-testing-of-cloud-infrastructure-provide-a-scenario-where-it-would-be-especially-useful)
   - [Terraform S3 Bucket with IAM Restrictions](infrastructure-as-code/README.iam.s3.md#10-write-a-terraform-configuration-snippet-to-provision-an-s3-bucket-and-restrict-its-access-to-a-specific-iam-user)
   - [Managing Terraform Modules for Large Projects](infrastructure-as-code/README.modules.md#11-describe-how-you-would-manage-terraform-modules-for-a-large-project-what-are-the-best-practices-for-module-versioning-and-reuse)
4. [Kubernetes & Orchestration](kubernetes_and_orchestration/README.md#kubernetes--orchestration)
   - [Kubernetes Resource Types Comparison](kubernetes_and_orchestration/README.k8s-resource.md#12-explain-the-difference-between-kubernetes-deployments-statefulsets-and-daemonsets-when-would-you-use-each)
   - [Deploying Applications with Helm](kubernetes_and_orchestration/README.deploying-with-helm.md#13-describe-the-process-of-deploying-an-application-using-helm-what-are-the-advantages-of-using-helm-charts)
   - [Injecting Secrets into Kubernetes Deployments](kubernetes_and_orchestration/README.injecting-secrets.md#14-how-would-you-securely-inject-secrets-into-a-kubernetes-deployment-provide-an-example-using-kubernetes-secrets)
   - [Horizontal Pod Autoscaling in Kubernetes](kubernetes_and_orchestration/README.hpa.md#15-given-a-scenario-where-you-need-to-scale-an-application-based-on-cpu-usage-explain-how-you-would-configure-horizontal-pod-autoscaling-in-kubernetes)
5. [Security & Best Practices]()