#!/bin/sh
# --- DIAGNOSTIC HELPER ---
# Run this script manually from your terminal to verify that you 
# can access the database user password stored in Secret Manager.
gcloud secrets versions access latest --secret="db-user-pw"
echo "\n"