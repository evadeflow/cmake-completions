Overview
--------
This project contains some shell completion functions I've cobbled together
for [CMake](http://cmake.org).  They currently contain project-specific
customizations that won't be of much interest to people who aren't working on
those same projects; however, they should serve as a good starting point for
anyone wishing to develop his own set of completions. I also have plans to
generalize the scripts to support "customizable customizations", but that
could take awhile.

I used CMake's [bash completion
file](https://github.com/Kitware/CMake/blob/master/Docs/bash-completion/cmake)
as a starting point, since I generally liked the approach it takes of using a
`CMakeCache.txt` file (if present) to generate completions for `-D` options.
But I didn't like how it leaves you 'flying blind' if you don't already have a
cache present, and the fact that options dependent on other options being set
(and therefore not yet in the cache) are invisible, so...  I hacked the
original bash completion script to provide a little help even if you are
running cmake for the first time.

TODO
----
* Add Zsh support
* Generalize the customization mechanism (maybe read customizations from a
  file, or autogenerate the completion script?)
* Fix duplicate entries when a CMakeCache.txt file *is* present. For example,
  if you type `-DGUI_<TAB>`, you'll see: `-DGUI_OPTION -DGUI_OPTION:STRING`.
  This is a little confusing.
* Related to the duplicates: consider ways of stripping the ':type' suffix
  from custom completions.  (Maybe bite the bullet and handle *all* values
  instead of just STRING/INTERNAL?)
