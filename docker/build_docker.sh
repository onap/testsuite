#!/bin/bash
#   COPYRIGHT NOTICE STARTS HERE
#
#   Copyright 2019 © Samsung Electronics Co., Ltd.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#   COPYRIGHT NOTICE ENDS HERE
set -e

#
# Build robot docker locally directly from git.
#

REPO_BASE=$(dirname $(git config --get remote.origin.url))
docker_folder_files=$(ls)
EXTRA_REPO_DIRS=()

function for_files
{
  local cmd=$1
  local files_dirs=$2
  local params=$3
  for f in ${files_dirs}
  do
    $cmd $f $params
  done
}

function git_clone
{
  local repo=$1
  local branch=$2
  local refspec=$3
  local target_dir=$4
  if [[ "${target_dir}" == "" ]]; then
    target_dir=$(basename ${repo})
  fi
  git clone -b ${branch} ${repo} ${target_dir}
  pushd ${target_dir}
  git fetch ${repo} ${refspec} && git checkout FETCH_HEAD
  popd
}

function clone_extra_repos
{
  # By default clone same branch from extras as testsuite itself
  CURRENT_BRANCH=$(git branch | grep \* | cut -d ' ' -f2)

  # Clone python-testing-utils
  PYTHON_TESTING_UTILS_BRANCH=${PYTHON_TESTING_UTILS_BRANCH:-${CURRENT_BRANCH}}
  PYTHON_TESTING_UTILS_REFSPEC=${PYTHON_TESTING_UTILS_REFSPEC:-refs/heads/${CURRENT_BRANCH}}
  git_clone ${REPO_BASE}/testsuite/python-testing-utils ${PYTHON_TESTING_UTILS_BRANCH} ${PYTHON_TESTING_UTILS_REFSPEC} testsuite/eteutils

  # Clone heatbridge
  HEATBRIDGE_BRANCH=${HEATBRIDGE_BRANCH:-${CURRENT_BRANCH}}
  HEATBRIDGE_REFSPEC=${HEATBRIDGE_REFSPEC:-refs/heads/${CURRENT_BRANCH}}
  git_clone ${REPO_BASE}/testsuite/heatbridge ${HEATBRIDGE_BRANCH} ${HEATBRIDGE_REFSPEC} testsuite/heatbridge

  DEMO_BRANCH=${DEMO_BRANCH:-${CURRENT_BRANCH}}
  DEMO_REFSPEC=${DEMO_REFSPEC:-refs/heads/${CURRENT_BRANCH}}
  git_clone ${REPO_BASE}/demo ${DEMO_BRANCH} ${DEMO_REFSPEC} demo

  # Add extra repos dirs to array for cleanup
  EXTRA_REPO_DIRS+=('testsuite/eteutils')
  EXTRA_REPO_DIRS+=('testsuite/heatbridge')
  EXTRA_REPO_DIRS+=('demo')
}

# Copy docker folder files to root for Docker context
for_files cp "${docker_folder_files}" ..

pushd ..

clone_extra_repos

# Docker build context created to repo root dir, now build docker
docker -D build -t onap/testsuite .

# Clean extra repo clones
for extra_dir in "${EXTRA_REPO_DIRS[@]}"
do
  for_files "rm -rf" ${extra_dir}
done
# Remove files copied to root
for_files rm "${docker_folder_files}"

popd

