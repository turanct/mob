#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

readonly PROGNAME=$(basename $0)
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

usage() {
	cat <<- EOF
	Usage: $PROGNAME subcommand

	$PROGNAME takes the current branch you're on as the "main branch".
	When you want to switch drivers, you just do "mob switch" which
	creates a wip commit and pushes it to a wip branch. It then
	switches you back to the main branch.

	On another computer, you can use "mob continue" to continue where you
	left off with the previous driver. It will take the wip commits from
	the wip branch and apply them on the "main branch".

	SUBCOMMANDS:
	   switch        Commit and push everything that changed on the wip branch.
	   continue      Continue working on the wip branch after somebody switched.
	EOF
}

main() {
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

    case $1 in
    switch)
        if [ $CURRENT_BRANCH_IS_WIP == 0 ]; then
            git pull --ff-only origin $BRANCH
            git checkout -b $WIPBRANCH || git checkout $WIPBRANCH
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

            git reset --soft $ORIGINALBRANCH
            git restore --staged .
            git stash push --include-untracked .
            git pull origin $WIPBRANCH
            git checkout $ORIGINALBRANCH
            git stash pop

            git branch -D $WIPBRANCH
            git push origin ":$WIPBRANCH"
        fi
        ;;
    *)
        usage
        ;;
    esac
}

main $ARGS
