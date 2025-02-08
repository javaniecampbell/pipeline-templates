# Pipeline Templates Repository

This repository contains reusable Azure Pipelines templates for Java 21 projects, including a Spring Boot pipeline and a Library pipeline.

## Folder Structure

```plaintext
/pipeline-templates
├── README.md                      # Overview and usage instructions
├── azure-pipelines.yml            # Example pipeline file demonstrating template usage
├── templates                      # Reusable YAML templates organized by type
│   ├── stages                     # Stage templates
│   │   ├── java_build_stage.yml   # Stage for Spring Boot pipeline
│   │   └── library_build_stage.yml# Stage for Library pipeline
│   ├── jobs                       # Job templates
│   │   ├── java_tests_job.yml
│   │   ├── helm_package_job.yml
│   │   ├── docker_build_job.yml
│   │   └── maven_deploy_job.yml
│   ├── tasks                      # Task templates
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
│   └── variables                  # Variable files
│       └── java_common_variables.yml
└── scripts                        # Helper scripts
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
