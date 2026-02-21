# Chapter 01: Getting Started with Terraform on Google Cloud - Learnings Summary

This chapter focuses on setting up your Terraform environment and establishing secure connections to Google Cloud Platform.

## 1. Environment Setup
- **Google Cloud Shell**: A convenient, pre-configured environment in the GCP console that includes Terraform.
- **Local Setup**: Installing Terraform locally and using the Google Cloud SDK (`gcloud`).

## 2. Authentication Methods
- **Key Files**: Using a JSON service account key. While simple, it requires careful handling of the sensitive file (e.g., adding it to `.gitignore`).
- **Service Account Impersonation**: A more secure approach that avoids long-lived keys by allowing a user to "impersonate" a service account temporarily.
- **Environment Variables**: Using `GOOGLE_APPLICATION_CREDENTIALS` to point to a key file.

## 3. Core Terraform Workflow
- `terraform init`: Initializes the working directory and downloads provider plugins.
- `terraform plan`: Shows a preview of the changes Terraform will make.
- `terraform apply`: Executes the actions to reach the desired state.

## 4. Parameterization
- **Variables**: Using `variable` blocks to define inputs.
- **`terraform.tfvars`**: A standard file to provide values for variables automatically.
- **Environment Variables**: Supplying variable values via `TF_VAR_name`.

---

> [!IMPORTANT]
> **Security First**: Prefer Service Account Impersonation over key files whenever possible to minimize the risk of credential leakage.

> [!TIP]
> Always run `terraform plan` and review its output before applying changes to avoid accidental resource destruction.
