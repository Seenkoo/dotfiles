brew-cask-upgrade() {
  brew-cask-outdated --verbose | while read cask versions; do
    echo "$cask $versions"
    (set -x; brew cask install $cask --force;)
  done
}

brew-cask-outdated() {
  # next line is not working in bash
  # local verbose=$(( ${@[(i)--verbose]} <= $# ))
  local -A casks=(${(fz)$(brew cask list --versions | sed -E "s/ (.*)/ '\1'/")})
  local -a cask_list=(${(ok)casks})
  integer idx=1
  local current=$cask_list[$idx]
  local -a outdated=( )

  brew cask info $cask_list | while read line; do
    if [[ ${(w)#line} -eq 2 && "$line" = "${current}: "* ]]; then
      local version=${${=line}[2]}
      local installed=$casks[$current]
      if [[ "$installed" != *"$version"* ]]; then
        if (( $verbose )); then
          outdated+="$current ($version) > (${(Q)installed})"
        else
          outdated+="$current"
        fi
      fi
      idx+=1
      current=$cask_list[$idx]
    fi
  done

  print -l $outdated
}
