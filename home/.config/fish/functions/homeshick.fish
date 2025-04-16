## Use homeshick for dotfile management

function homeshick
  if test \( (count $argv) = 2 -a "$argv[1]" = "cd" \)
    cd "$HOME/.homesick/repos/$argv[2]"
  else if set -q HOMESHICK_DIR
    eval $HOMESHICK_DIR/bin/homeshick (string escape -- $argv)
  else if set homeshick (type -P homeshick 2> /dev/null)
    eval $homeshick (string escape -- $argv)
  else
    eval $HOME/.homesick/repos/homeshick/bin/homeshick (string escape -- $argv)
  end
end
