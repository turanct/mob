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
	When you use "mob start", it creates a wip branch for the current
	"main branch" you're on. When you want to switch drivers, you just
	do "mob switch" which creates a wip commit and pushes it to the wip
	branch. It then switches you back to the main branch.

	On another computer, you can use "mob continue" to continue where you
	left off with the previous driver.

	When you're ready to make a commit that's not a wip, you can use
	"mob commit" which will take the wip commits and apply their changes
	to the main branch, but not actually commit them. At that point you
	can create a deliberate commit.

	SUBCOMMANDS:
	   start         Prepare the wip-branch based the "main branch you're on".
	   switch        Commit and push everything that changed on the wip branch.
	   continue      Continue working on the wip branch after somebody switched.
	   commit        Prepare a commit to the "main branch" based on the wip commits.
	EOF
}

main() {
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

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
    *)
        usage
        ;;
    esac
}

main $ARGS
