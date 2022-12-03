#!/bin/sh
set -e

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

INPUT_AUTHOR_EMAIL=${INPUT_AUTHOR_EMAIL:-'github-actions[bot]@users.noreply.github.com'}
INPUT_AUTHOR_NAME=${INPUT_AUTHOR_NAME:-'github-actions[bot]'}
INPUT_COAUTHOR_EMAIL=${INPUT_COAUTHOR_EMAIL:-''}
INPUT_COAUTHOR_NAME=${INPUT_COAUTHOR_NAME:-''}
INPUT_MESSAGE=${INPUT_MESSAGE:-"chore: autopublish ${timestamp}"}
INPUT_BRANCH=${INPUT_BRANCH:-master}
INPUT_FORCE=${INPUT_FORCE:-false}
INPUT_TAGS=${INPUT_TAGS}
INPUT_EMPTY=${INPUT_EMPTY:-false}
INPUT_DIRECTORY=${INPUT_DIRECTORY:-'.'}
INPUT_TAGS_ONLY=${INPUT_TAGS_ONLY:-false}
REPOSITORY=${INPUT_REPOSITORY:-$GITHUB_REPOSITORY}

if ${INPUT_TAGS_ONLY}; then
    echo "Push to tags $INPUT_TAGS";
else
    echo "Push to branch $INPUT_BRANCH";
fi

[ -z "${INPUT_GITHUB_TOKEN}" ] && {
    echo 'Missing input "github_token: ${{ secrets.GITHUB_TOKEN }}".';
    exit 1;
};

if ${INPUT_EMPTY}; then
    _EMPTY='--allow-empty'
fi

if ${INPUT_FORCE}; then
    _FORCE_OPTION='--force'
fi

[ -n "${INPUT_TAGS}" ] && {
    _TAGS='--tags'
}

if ${INPUT_TAGS_ONLY}; then
    _HEAD=''
else
    _HEAD="HEAD:${INPUT_BRANCH}"
fi

cd "${INPUT_DIRECTORY}"

remote_repo="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${REPOSITORY}.git"

git config http.sslVerify false
git config --local user.email "${INPUT_AUTHOR_EMAIL}"
git config --local user.name "${INPUT_AUTHOR_NAME}"

git add -A

if [ -n "${INPUT_COAUTHOR_EMAIL}" ] && [ -n "${INPUT_COAUTHOR_NAME}" ]; then
    git commit -m "${INPUT_MESSAGE}
    

Co-authored-by: ${INPUT_COAUTHOR_NAME} <${INPUT_COAUTHOR_EMAIL}>" $_EMPTY || exit 0
else
    git commit -m "${INPUT_MESSAGE}" $_EMPTY || exit 0
fi

[ -n "${INPUT_TAGS}" ] && {
    git tag "${INPUT_TAGS}"
}

git push "${remote_repo}" $_HEAD --follow-tags $_FORCE_OPTION $_TAGS;
