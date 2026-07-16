#!/usr/bin/env bash
# ===============================================================
# Bootstrap Runner - per project via parameters
# USAGE:
#   ./run_bootstrap.sh in-dev-network          -> one project
#   ./run_bootstrap.sh in-dev-network plan     -> plan only
#   ./run_bootstrap.sh in                      -> all in-* projects
#   ./run_bootstrap.sh us                      -> all us-* projects
#   ./run_bootstrap.sh all                     -> all 22 projects
# ===============================================================
set -euo pipefail

ENV="${1:-}"
ACTION="${2:-apply}"

ALL_ENVS=(in-dev-network in-staging-network in-prod-network in-dev-tms in-dev-vms in-dev-analytics in-staging-tms in-staging-vms in-prod-tms in-prod-vms in-prod-analytics us-dev-network us-staging-network us-prod-network us-dev-tms us-dev-vms us-dev-analytics us-staging-tms us-staging-vms us-prod-tms us-prod-vms us-prod-analytics)

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
  "") echo "Usage: ./run_bootstrap.sh <env|in|us|all> [plan|apply]"; echo "Envs: ${ALL_ENVS[*]}"; exit 1 ;;
  all) for e in "${ALL_ENVS[@]}"; do run_one "$e"; done ;;
  in)  for e in "${ALL_ENVS[@]}"; do [[ "$e" == in-* ]] && run_one "$e"; done ;;
  us)  for e in "${ALL_ENVS[@]}"; do [[ "$e" == us-* ]] && run_one "$e"; done ;;
  *)   run_one "$ENV" ;;
esac

echo ""
echo "Bootstrap complete!"
