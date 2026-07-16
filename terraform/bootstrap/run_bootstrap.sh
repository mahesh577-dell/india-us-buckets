#!/usr/bin/env bash
# ===============================================================
# Bootstrap Runner - per project via parameters
# USAGE:
#   ./run_bootstrap.sh india-host-dev          -> one project
#   ./run_bootstrap.sh india-host-dev plan     -> plan only
#   ./run_bootstrap.sh india                   -> all india projects
#   ./run_bootstrap.sh us                      -> all us projects
#   ./run_bootstrap.sh all                     -> all 22 projects
# ===============================================================
set -euo pipefail

ENV="${1:-}"
ACTION="${2:-apply}"

ALL_ENVS=(india-host-dev india-host-staging india-host-prod india-tms-dev india-vms-dev india-analytics-dev india-tms-staging india-vms-staging india-tms-prod india-vms-prod india-analytics-prod us-host-dev us-host-staging us-host-prod us-tms-dev us-vms-dev us-analytics-dev us-tms-staging us-vms-staging us-tms-prod us-vms-prod us-analytics-prod)

mkdir -p states

run_one() {
  local env="$1"
  local tfvars="projects/${env}.tfvars"
  [ -f "$tfvars" ] || { echo "missing $tfvars"; exit 1; }
  echo ""
  echo "=== Bootstrapping: $env ==="
  terraform init -input=false
  if [ "$ACTION" = "plan" ]; then
    terraform plan -state="states/${env}.tfstate" -var-file="$tfvars" -input=false
  else
    terraform apply -state="states/${env}.tfstate" -var-file="$tfvars" -input=false -auto-approve
    echo "done: $env"
  fi
}

case "$ENV" in
  "") echo "Usage: ./run_bootstrap.sh <env|india|us|all> [plan|apply]"; echo "Envs: ${ALL_ENVS[*]}"; exit 1 ;;
  all)   for e in "${ALL_ENVS[@]}"; do run_one "$e"; done ;;
  india) for e in "${ALL_ENVS[@]}"; do [[ "$e" == india-* ]] && run_one "$e"; done ;;
  us)    for e in "${ALL_ENVS[@]}"; do [[ "$e" == us-* ]] && run_one "$e"; done ;;
  *)     run_one "$ENV" ;;
esac

echo ""
echo "Bootstrap complete!"
