# Remote mob programming switching drivers using git

A bare-bones mob programming tool designed for simplicity and clean git history.


## Why don't you use remotemobprogramming/mob?

[remotemobprogramming/mob](https://github.com/remotemobprogramming/mob) is a great app, it has a lot of nice features, a bunch of supporters and it's in all ways better than this app. However, we needed to keep our git history clean, and that's the one thing that it doesn't do.

How that app works, is that after working on something, all commits (containing the uncommitted work that was passed on when switching drivers) on the wip branch are squashed together, resulting in one big commit for all the work done. However, our team values small, self-contained commits that are preciously built and have a good commit message explaining why we made certain decisions, etc. We find that this helps us (and other developers) understand why we made certain decisions when we need to come back to older code.

Although it's possible to achieve this with the other application with some effort, we chose to create this MVP doing just what we need it to do, in exactly the way we envisioned it to work.


## How does it work?

- It takes the current branch you're on as the "main branch"
- When you want to switch drivers, you just do `mob switch`
  which creates a wip commit and pushes it to a wip branch.
  It then takes you back to the "main branch".
- On another computer, you can use `mob continue` to continue where you
  left off with the previous driver. This takes the wip commit and
  applies it like a patch to your working directory, as if you did
  a `git stash pop` of a remote stash.
- You can now continue working exactly where you left off before
  you switched drivers.


## Installing

1. clone this repo somewhere
1. symlink the executable to `/usr/local/bin`

```sh
git clone https://github.com/turanct/mob.git
cd mob
ln -s $(pwd)/mob.sh /usr/local/bin/mob
```


## Commands

- `mob switch`
- `mob continue`


## Credit & Why

- https://github.com/remotemobprogramming/mob
- https://twitter.com/tinydroptest2/status/1238562914786775041
