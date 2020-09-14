#!/bin/zsh
() {
  emulate -L zsh -o extendedglob -o NO_shortloops -o warncreateglobal

  # Get access to `functions` & `commands` arrays.
  zmodload zsh/parameter

  # Workaround for https://github.com/zdharma/zinit/issues/366
  [[ -v functions[.zinit-shade-off] ]] && .zinit-shade-off "${___mode:-load}"

  typeset -gU FPATH fpath=( ${${(%):-%x}:A:h}/* $fpath )
  typeset -gHa _autocomplete__options=(
    localoptions extendedglob NO_completeinword NO_shortloops warncreateglobal )

  .autocomplete.no-op() {
    :
  }

  zmodload zsh/complist
  functions[compinit]=$functions[.autocomplete.no-op]
  autoload -Uz .autocomplete.compinit
  compdef() {
    emulate -L zsh -o extendedglob -o NO_shortloops -o warncreateglobal
    .autocomplete.compinit
    compdef $@
  }

  # In case we're sourced _after_ `zsh-autosuggestions`
  autoload +X -Uz add-zsh-hook .autocomplete.autosuggest
  [[ -v _zsh_autosuggest_start ]] &&
    .autocomplete.autosuggest

  # In case we're sourced _before_ `zsh-autosuggestions`
  functions[__autocomplete__.add-zsh-hook]=$functions[add-zsh-hook]
  add-zsh-hook() {
    if [[ $@[(ie)_zsh_autosuggest_start] -gt $#@ ]]; then
      __autocomplete__.add-zsh-hook "$@"
    else
      .autocomplete.autosuggest
    fi
  }

  autoload -Uz .autocomplete.__init__ && .autocomplete.__init__
  local mod; for mod in \
      config widget key key-binding recent-dirs async-highlight async-completion; do
    if ! zstyle -t :autocomplete: $mod false no off 0; then
      mod=.autocomplete.$mod
      autoload -Uz $mod && $mod
    fi
  done

  # Workaround for https://github.com/zdharma/zinit/issues/366
  [[ -v functions[.zinit-shade-on] ]] && .zinit-shade-on "${___mode:-load}"

  return 0
}
