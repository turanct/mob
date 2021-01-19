#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

readonly WHOAMI=$(whoami)
readonly LOGFILE=$(mktemp /tmp/wip-mob-logs.XXXXXX)

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

mob-switch() {
    if [ $CURRENT_BRANCH_IS_WIP == 0 ]; then
        printf 'log: %s\n' "$LOGFILE"

        colorline "Deleting local & remote wip branch..."
        git branch -D $WIPBRANCH >> $LOGFILE 2>&1 || true
        git push origin ":$WIPBRANCH" >> $LOGFILE 2>&1 || true

        colorline "Stashing changes..."
        git stash push --include-untracked . >> $LOGFILE 2>&1
        git stash apply >> $LOGFILE 2>&1

        colorline "Making sure we are up-to-date with remote..."
        git pull origin $BRANCH >> $LOGFILE 2>&1
        git checkout -b $WIPBRANCH >> $LOGFILE 2>&1

        colorline "Creating wip commit..."
        git add . >> $LOGFILE 2>&1
        git commit -m "wip $WHOAMI" >> $LOGFILE 2>&1 || true

        colorline "Pushing changes to '$WIPBRANCH'..."
        git push origin $WIPBRANCH >> $LOGFILE 2>&1
        git checkout $ORIGINALBRANCH >> $LOGFILE 2>&1

        colorline "Done"
    fi
}

mob-continue() {
    if [ $CURRENT_BRANCH_IS_WIP == 0 ]; then
        printf 'log: %s\n' "$LOGFILE"

        colorline "Making sure we are up-to-date with remote..."
        git remote update >> $LOGFILE 2>&1
        git pull --rebase origin $BRANCH >> $LOGFILE 2>&1
        git checkout $WIPBRANCH >> $LOGFILE 2>&1
        git pull --rebase origin $WIPBRANCH >> $LOGFILE 2>&1

        colorline "Applying changes to our local branch..."
        git reset --soft $ORIGINALBRANCH >> $LOGFILE 2>&1
        git restore --staged . >> $LOGFILE 2>&1
        git stash push --include-untracked . >> $LOGFILE 2>&1
        git pull --rebase origin $WIPBRANCH >> $LOGFILE 2>&1
        git checkout $ORIGINALBRANCH >> $LOGFILE 2>&1
        git stash pop >> $LOGFILE 2>&1

        colorline "Deleting local & remote wip branch..."
        git branch -D $WIPBRANCH >> $LOGFILE 2>&1
        git push origin ":$WIPBRANCH" >> $LOGFILE 2>&1

        colorline "Done"
    fi
}

colorline() {
    printf -- '\033[37m-\033[36m %s\033[0m\n' "$1"
}

main() {
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

    case $1 in
    switch)
        mob-switch
        ;;
    continue)
        mob-continue
        ;;
    *)
        usage
        ;;
    esac
}

main $ARGS
