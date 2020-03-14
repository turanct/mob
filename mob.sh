#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

readonly ARGS="$@"

readonly WHOAMI=$(whoami)

readonly BRANCH=$(git branch --show-current)
readonly WIPPREFIX="wip-mob-"
readonly ORIGINALBRANCH=${BRANCH/$WIPPREFIX}

if [[ "$ORIGINALBRANCH" = "$BRANCH" ]] ; then
    readonly WIPBRANCH="$WIPPREFIX$BRANCH"
    readonly CURRENT_BRANCH_IS_WIP=0
else
    readonly WIPBRANCH="$BRANCH"
    readonly CURRENT_BRANCH_IS_WIP=1
fi

main() {
    case $1 in
    start)
        if [ "$CURRENT_BRANCH_IS_WIP" == 0 ]; then
            git pull --ff-only origin $BRANCH
            git checkout -b $WIPBRANCH
        fi
        ;;
    switch)
        if [ $CURRENT_BRANCH_IS_WIP == 1 ]; then
            git add .
            git commit -m "wip $WHOAMI" || true
            git push origin $WIPBRANCH
            git checkout $ORIGINALBRANCH
        fi
        ;;
    continue)
        if [ $CURRENT_BRANCH_IS_WIP == 0 ]; then
            git remote update
            git pull --rebase origin $BRANCH
            git checkout $WIPBRANCH
            git pull --rebase origin $WIPBRANCH
        fi
        ;;
    commit)
        if [ $CURRENT_BRANCH_IS_WIP == 1 ]; then
            git add .
            git commit -m "wip $WHOAMI" || true

            git remote update
            git pull --rebase origin $WIPBRANCH
            git checkout $ORIGINALBRANCH
            git pull --rebase origin $ORIGINALBRANCH

            git checkout $WIPBRANCH
            git checkout -b "wip-commit-$BRANCH"
            git reset --soft $ORIGINALBRANCH

            git checkout $ORIGINALBRANCH
            git branch -d "wip-commit-$BRANCH"
            git branch -D $WIPBRANCH
            git push origin ":$WIPBRANCH"
        fi
        ;;
    esac
}

main $ARGS
