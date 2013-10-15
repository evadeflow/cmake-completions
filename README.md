Overview
--------
This project contains some shell completion functions I've cobbled together
for [CMake](http://cmake.org).  They currently contain project-specific
customizations that won't be of much interest to people who aren't working on
those same projects; however, they should serve as a good starting point for
anyone wishing to develop his own set of completions. I also have plans to
generalize the scripts to support "customizable customizations", but that
could take awhile.

For Bash, I used CMake's [bash completion
file](https://github.com/Kitware/CMake/blob/master/Docs/bash-completion/cmake)
as a starting point, since I generally liked the approach it takes of using a
`CMakeCache.txt` file (if present) to generate completions for `-D` options.
But I didn't like how it leaves you 'flying blind' if you don't already have a
cache present, and the fact that options dependent on other options being set
(and therefore not yet in the cache) are invisible, so...  I hacked the
original bash completion script to provide a little help even if you are
running cmake for the first time.

For Zsh, I started with [this script](https://github.com/skroll/zsh-cmake-completion/blob/master/_cmake) and hacked it to support some (hard-coded) custom options for projects I'm working on.  This script does _not_ read from a CMakeCache.txt, but maybe I'll add that ability someday...

TODO
----
* Generalize the customization mechanism (maybe read customizations from a
  file, or autogenerate the completion script?)
* Add support to ABORT if the user is invoking CMake from a folder containing
  a CMakeLists.txt file (this is probably better handled via a shell wrapper
  function?)
