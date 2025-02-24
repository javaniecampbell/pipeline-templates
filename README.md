# Pipeline Templates Repository

This repository contains reusable Azure Pipelines templates for Java 21 projects, including both Spring Boot and Library pipelines. The templates are organized into stages, jobs, tasks, and variables to help enforce best practices and ensure consistency across your CI/CD processes.

## Folder Structure

```plaintext
/pipeline-templates
├── README.md                      # Overview, usage instructions and change log
├── azure-pipelines.yml            # (Optional) Example pipeline file demonstrating template usage & showing how to call templates
├── templates                      # Reusable YAML templates organized by type
│   ├── stages                     # Stage templates i.e. Templates defining full pipeline stages
│   │   ├── java_build_stage.yml   # Stage for Spring Boot pipeline
│   │   └── library_build_stage.yml# Stage for Library pipeline
│   ├── jobs                       # Job templates i.e. Reusable job templates
│   │   ├── java_tests_job.yml
│   │   ├── helm_package_job.yml
│   │   ├── docker_build_job.yml
│   │   └── maven_deploy_job.yml
│   ├── tasks                      # Task templates i.e. Atomic task templates (each file encapsulates one task)
│   │   ├── java_tool_installer.yml
│   │   ├── maven_authenticate.yml
│   │   ├── maven_test.yml
│   │   ├── publish_code_coverage.yml
│   │   ├── helm_installer.yml
│   │   ├── helm_package.yml
│   │   ├── generate_chart_name.yml
│   │   ├── keyvault_pull.yml
│   │   ├── helm_login.yml
│   │   ├── helm_push.yml
│   │   ├── docker_build.yml
│   │   ├── docker_push.yml
│   │   └── ermetic_scan.yml
│   └── variables                  # Variable files i.e. Global variable definitions or environment-specific variables
│       └── java_common_variables.yml
└── scripts                        # Helper scripts i.e. Non-YAML helper scripts (e.g. the parse_yaml function)
    └── parse_yaml.sh

```

## Usage

Reference the templates from your consuming pipeline YAML file by adding a `resources` block. For example:

```yaml
resources:
  repositories:
    - repository: templates
      type: git
      name: YourOrg/pipeline-templates
      ref: refs/heads/main

stages:
- template: templates/stages/java_build_stage.yml@templates
  parameters:
    vmImageName: 'ubuntu-latest'
    dockerRegistryServiceConnection: 'your-docker-service-connection'
    imageRepository: 'spring-boot-template'
    containerRegistry: 'your-container-registry'
See the individual template files for more details on available parameters.
```

### Base Template Usage

This repository is intended to serve as a centralized source for pipeline templates that can be extended in your own projects. The two base templates are:

- **base-springboot-azure-pipelines.yml** – for Java 21 Spring Boot applications.
- **base-library-azure-pipelines.yml** – for Java 21 Library projects.

### How to Consume the Templates

In your own project repository, create a pipeline YAML file (for example, `azure-pipelines.yml`) that references the centralized templates repository. Use the `resources` block to declare the external repository, and then extend the desired base template using the `extends` syntax.

#### Example: Consuming the Spring Boot Base Template

```yaml
trigger:
  branches:
    include:
      - develop
      - release/*

resources:
  repositories:
    - repository: templates
      type: git
      name: YourOrg/pipeline-templates # Replace with your organization and repository name
      ref: refs/heads/main

extends:
  template: base-springboot-pipeline.yml@templates
  parameters:
    vmImageName: "ubuntu-latest"
    dockerRegistryServiceConnection: "20240904-gr-dev-agile-01-serv-conn"
    prodDockerRegistryServiceConnection: "azdevopsagile01-ACR Connection"
    imageRepository: "spring-boot-template"
    containerRegistry: "grdevagile01.azurecr.io"
    devHelmChartContainerRegistry: "grdevagile02.azurecr.io/helm"
    prodHelmChartContainerRegistry: "azdevopsagile01.azurecr.io/helm"
    helmChartPath: "helm-chart"
    artifactDestination: "$(Build.ArtifactStagingDirectory)"
```

#### Example: Consuming the Library Base Template

```yaml
trigger:
  branches:
    include:
      - develop

resources:
  repositories:
    - repository: templates
      type: git
      name: YourOrg/pipeline-templates # Replace with your organization and repository name
      ref: refs/heads/main

extends:
  template: base-library-pipeline.yml@templates
  parameters:
    vmImageName: "ubuntu-latest"
```

### Explanation

- **Resources Block:**  
  The `resources` section declares an external repository (here named `templates`) where all centralized pipeline templates reside. This enables you to reference files such as the base templates, stage templates, job templates, and task templates stored in this repository.

- **Extends Block:**  
  The `extends` block references one of the base templates (e.g., `base-springboot-pipeline.yml` or `base-library-pipeline.yml`) using the repository alias (`@templates`). You then provide a set of parameters to customize the behavior of the base pipeline.

- **Parameterization:**  
  All configurable values (such as VM image, service connections, registry URLs, and paths) are defined as parameters in the base templates. When consuming the template, these parameters can be overridden to suit your project’s requirements.

## Additional Resources

- [Baseline Pipelines Architecture Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/architectures/devops-pipelines-baseline-architecture?view=azure-devops)
- [Azure DevOps Pipeline Templates – Includes and Extends](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops) 

This README serves as a guide to help you quickly onboard yourselves to the centralized pipeline templates and understand how to extend them in your projects, with step-by-step instructions on how to consume the templates using the `resources` and `extends` blocks, along with usage examples for both the Spring Boot and Library base templates.

Happy coding!
