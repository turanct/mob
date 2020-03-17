# Remote mob programming switching drivers using git

## How does it work?

- It takes the current branch you're on as the "main branch"
- When you want to switch drivers, you just do `mob switch`
  which creates a wip commit and pushes it to a wip branch.
  It then takes you back to the main branch.
- On another computer, you can use `mob continue` to continue where you
  left off with the previous driver.


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
