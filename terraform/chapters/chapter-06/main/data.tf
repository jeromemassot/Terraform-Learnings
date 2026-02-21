# READ-ONLY LINK TO FOUNDATION LAYER
# While this 'main' module has its own backend (to store its own state),
# it uses this data source to READ the outputs from the foundation layer.
# This allows us to retrieve 'network_self_link' and other networking details
# without hardcoding them or re-creating them.
data "terraform_remote_state" "foundation" {
  backend = "gcs"
  config = {
    bucket = "<PROJECT_ID>-tf-state"
    prefix = "chap06/foundation"
  }
}

