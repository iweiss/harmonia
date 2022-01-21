#!/bin/bash
set -eo pipefail

readonly GALAXY_YML='galaxy.yml'
readonly UPSTREAM_NS='middleware_automation'
readonly DOWNSTREAM_NS='redhat'
readonly DEFAULT_UPSTREAM_GIT_BRANCH='main'

echo GIT_REPOSITORY_URL: "${GIT_REPOSITORY_URL}"
echo GIT_REPOSITORY_BRANCH: "${GIT_REPOSITORY_BRANCH}"
echo WORKDIR: "${WORKDIR}"
echo VERSION: "${VERSION}"

cd "${WORKDIR}"
if [ -n "${GIT_REPOSITORY_URL}" ]; then
  echo "Syncronizing with upstream ${GIT_REPOSITORY_URL} repository..."
  git remote add upstream "${GIT_REPOSITORY_URL}"
  git pull --rebase upstream "${DEFAULT_UPSTREAM_GIT_BRANCH}"
  echo 'Done.'
fi

echo -n "Change collection namespace from ${UPSTREAM_NS} to ${DOWNSTREAM_NS}..."
for file_to_edit in $(grep -e "${UPSTREAM_NS}" -r . | cut -f1 -d: | sort -u)
do
  echo -n "Editing ${file_to_edit}..."
  sed -i "${file_to_edit}" \
      -e "s/${UPSTREAM_NS}/${DOWNSTREAM_NS}/"
   echo 'Done.'
done

if [ -n "${VERSION}" ]; then
  readonly TAG="${VERSION}-${DOWNSTREAM_NS}"
  echo -n "Bump version to ${TAG}..."
  sed -i "${GALAXY_YML}" \
      -e "s/^\(version: \).*$/\1\"${TAG}\"/"
  echo 'Done.'
fi

git diff --no-color .
ansible-galaxy collection build .

if [ -n "${VERSION}" ]; then
  echo "Tagging release ${TAG}"
  git tag "${TAG}"
  git commit -m "Release ${TAG}-${DOWNSTREAM_NS}" -a
  echo "Create branch"
  if [ -z "${GIT_REPOSITORY_BRANCH}" ]; then
    echo "No GIT_REPOSITORY_BRANCH provided, abort."
    exit 1
  fi
  git push origin "${GIT_REPOSITORY_BRANCH}:${TAG}"
fi