# Study Guide: Terraform for Google Cloud Essential Guide

This guide aligns the chapters of the book in your `references/` folder with the structure of this repository.

## Part 1: Fundamentals

### [ ] Chapter 1: Getting Started
- **Topics**: DevOps, Cloud Shell, Basic Terraform Workflow.
- **Action**: Try running basic `terraform` commands in Cloud Shell or locally.

### [ ] Chapter 2: Exploring Terraform
- **Topics**: State, Backend state, Meta-arguments (`count`, `for_each`), `self_link`.
- **Action**: Experiment with different backends in `terraform/environments/`.

# Terraform for Google Cloud - Study Guide

## Chapter 01: Authenticating Terraform on Google Cloud

This chapter covers the essential methods for connecting Terraform to Google Cloud.

### Authentication Methods

| Method | Description | Best For |
| :--- | :--- | :--- |
| **Cloud Shell** | Automatic authentication when running within Google Cloud Console. | Fast testing, POCs. |
| **Environment Variables** | Points to a JSON key file using `GOOGLE_APPLICATION_CREDENTIALS`. | CI/CD pipelines, local development. |
| **Key File (Provider)** | Explicitly specifying `credentials = "path/to/key.json"` in the provider block. | Learning, specific account usage. |
| **Service Account Impersonation** | **(Recommended)** Securely assume the identity of a service account without long-lived keys. | Production, secure local dev. |

---

### Key Concept: Service Account Impersonation

Impersonation is the most secure method because it uses short-lived tokens instead of sensitive JSON key files stored on disk.

#### Setup Steps:
1. **Login with User Account:**
   ```bash
   gcloud auth application-default login
   ```
2. **Assign `Service Account Token Creator` Role:**
   Your user account needs this role on the target service account.
   ```bash
   gcloud iam service-accounts add-iam-policy-binding [SERVICE_ACCOUNT_EMAIL] \
       --member="user:[YOUR_EMAIL]" \
       --role="roles/iam.serviceAccountTokenCreator"
   ```
3. **Configure Terraform Provider:**
   The provider automatically uses the ADC (Application Default Credentials) if no credentials file is specified.

---

### Useful Commands
- `gcloud auth login`: Standard user login.
- `gcloud config set project [PROJECT_ID]`: Sets the active project.
- `./set-project-id [PROJECT_ID]`: Repository helper script to update project IDs in code.

### [ ] Chapter 3: Writing Efficient Code
- **Topics**: Types, Values, Expressions, Functions, Data Sources, Outputs.
- **Action**: Use `notebooks/` to test Terraform expressions and functions.

### [ ] Chapter 4: Reusable Code with Modules
- **Topics**: Building modules, flexibility, GCS/Git sharing.
- **Action**: Build your first modules in `terraform/modules/`.

### [ ] Chapter 5: Managing Environments
- **Topics**: Resource hierarchy, Workspaces vs. Directory structure, Remote states.
- **Action**: Implement environment-specific folders in `terraform/environments/`.

## Part 2: Practical Deployment

### [ ] Chapter 6: Three-Tier Architecture
- **Topics**: Foundations, Database, MIG, Load Balancing.
- **Action**: Deploy a full architecture in a new environment folder.

---
*Note: You can check off these items as you progress!*
