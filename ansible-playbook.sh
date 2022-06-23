#!/bin/bash
set -eo pipefail

readonly PLAYBOOK=${PLAYBOOK:-'playbooks/playbook.yml'}

if [ ! -d "${WORKDIR}" ]; then
  echo "WORKDIR ${WORKDIR} does not exists or is not a directory."
  exit 1
fi

if [ ! -e "${PLAYBOOK}" ]; then
  echo "Playbook does not exits: ${PLAYBOOK}."
  exit 2
fi

cd "${WORKDIR}"
ansible-playbook "${PLAYBOOK}"
