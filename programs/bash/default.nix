{ ... }: {
  programs.bash = {
    completion.enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -alh";
      la = "ls -A";
      l = "ls -CF";
      nv = "nvim";
      vinfo = "info --vi-keys";
    };
    enableLsColors = true;
    vteIntegration = true;
    interactiveShellInit = ''
      HISTCONTROL=ignorespace:ignoreboth
      HISTSIZE=100000
      HISTFILESIZE=100000
      shopt -s histappend

      shopt -s checkwinsize
      shopt -s extglob
      shopt -s globstar
      shopt -s checkjobs
      shopt -s cdspell
      shopt -o -s vi

      stty stop '''
    '';
    promptInit = ''
      # Provide a nice prompt if the terminal supports it.
      if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
        USER_COLOR="1;31"
        ((UID)) && USER_COLOR="1;32"
        PS1="\n\[\e[''${USER_COLOR}m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w $\[\e[0m\] "
        if [ -z "$INSIDE_EMACS" ]; then
          PS1="\[\e]0;\u@\h:\w\a\]$PS1"
        fi
        if test "$TERM" = "xterm"; then
          PS1="\e]2;\h:\u:\w\007$PS1"
        fi
      fi
    '';
  };
}
