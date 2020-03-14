# Remote mob programming switching drivers using git

## How does it work?

- It takes the current branch you're on as the "main branch"
- When you use `mob start`, it creates a wip branch for the current
  main branch you're on. When you want to switch drivers, you just do
- `mob switch` which creates a wip commit and pushes it to the wip
  branch. It then switches you back to the main branch.
- On another computer, you can use `mob continue` to continue where you
  left off with the previous driver.
- When you're ready to make a commit that's not a wip, you can use
  `mob commit` which will take the wip commits and apply their changes
  to the main branch, but not actually commit them. At that point you
  can create a deliberate commit.


## Installing

1. clone this repo somewhere
1. symlink the executable to `/usr/local/bin`

```sh
git clone https://github.com/turanct/mob.git
cd mob
ln -s $(pwd)/mob.sh /usr/local/bin/mob
```


## Commands

- `mob start`
- `mob switch`
- `mob continue`
- `mob commit`


## Credit & Why

- https://github.com/remotemobprogramming/mob
- https://twitter.com/tinydroptest2/status/1238562914786775041
