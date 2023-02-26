{ config, pkgs, ... }:

{

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = "nix-command flakes";
    };
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "alex800121";
  home.homeDirectory = "/home/alex800121";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  dconf.settings = {
    "org/gnome/desktop/peripherals/touchpad".tap-to-click = true;
    "org/gnome/desktop/peripherals/touchpad".disable-while-typing = true;
    "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = (with pkgs; [
    firefox
    microsoft-edge
    curl unzip wget ripgrep vim
    gcc_multi gccMultiStdenv
    neofetch freshfetch
    python39
    dmidecode
    xclip
    nodejs
    libchewing
    gtk3
  ]) ++ (with pkgs.python39Packages; [
    pip
    distro psutil distutils_extra distlib  devtools click power py-dmidecode
    setuptools setuptools-git
  ]);

  home.file = {
    # "\.haskeline".source = programs/haskell/.haskeline;
    # "\.ghci".source = programs/haskell/.ghci;
    # "\.cabal" = {
    #   recursive = true;
    #   source = programs/cabal/.cabal;
    # };
    # "\.bash_logout".source = programs/bash/.bash_logout;
  };
  
  programs.bash = {
    enable = true;
    enableCompletion = true;
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    shellOptions = [
       "histappend" "checkwinsize" "extglob" "globstar" "checkjobs" "-cdspell"
    ];
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      sshrpi4 = "ssh alex800121@alexrpi4gate.duckdns.org";
      sshubuntu = "ssh alex800121@alexubuntugate.duckdns.org";
      sshdormrpi = "ssh -p 40000 pi@alexrpi4gate.duckdns.org";
      sshdormubu = "ssh -p 40000 pi@alexubuntugate.duckdns.org";
      nv = "nvim";
    };
    historyControl = [ "ignoredups" "ignorespace" ];
    historyFileSize = 100000;
    historySize = 10000;
    bashrcExtra = ''
      if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
        . $HOME/.nix-profile/etc/profile.d/nix.sh;
      fi

      PS1='\[\033[01;34m\]\W \[\033[00m\]\$ '
      set -o vi
    '';
  };

  programs.readline = {
    enable = true;
    extraConfig = "set completion-ignore-case On";
  };

  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
  };
  xdg.configFile."alacritty" = {
    # recursive = true;
    source = programs/alacritty;
  };

  programs.neovim = let
    smart-splits-nvim = pkgs.vimUtils.buildVimPlugin {
      name = "smart-splits-nvim";
      src = pkgs.fetchFromGitHub {
        owner = "mrjones2014";
        repo = "smart-splits.nvim";
        rev = "c8d80d90f3c783ac0ea21f256c74d541a7b66a72";
        sha256 = "0vchzaflnrbxnmq2j2zfms8a6xadj75sq0jpxvgmngry5fyb6r1z";
      };
    };
  in {
    enable = true;
    plugins = ( with pkgs.vimPlugins; [
      # packer-nvim
      dracula-vim
      popup-nvim
      plenary-nvim
      comment-nvim
      nvim-web-devicons
      nvim-tree-lua
      bufferline-nvim
      vim-bbye
      lualine-nvim
      toggleterm-nvim
      nvim-cmp
      cmp-nvim-lua
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp_luasnip
      luasnip
      friendly-snippets
      nvim-lspconfig
      telescope-nvim
      nvim-treesitter
      playground
      nvim-ts-rainbow
      smart-splits-nvim
    ] );
    extraPackages = ( with pkgs; [
      rnix-lsp
      fd
      tree-sitter
    ] );
  };
  xdg.configFile."nvim" = {
    # recursive = true;
    source = programs/nvim;
  };

  programs.git = {
    enable = true;
    userName = "alex800121";
    userEmail = "alex800121@hotmail.com";
  };

  programs.gh = {
    enable = true;
    enableGitCredentialHelper = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
      };
      editor = "nvim";
    };
  };
  
  programs.htop.enable = true;

  programs.tmux = {
    enable = true;
    sensibleOnTop = true;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
    ];
    terminal = "screen-256color";
    # keyMode = "vi";
    baseIndex = 1;
    historyLimit = 10000;
    prefix = "C-a";
    shortcut = "a";
    escapeTime = 0;
    extraConfig = ''
      setw -g mode-keys vi
      # reload config without killing server
      # bind r source-file ~/.tmux.conf \; display-message "Config reloaded"

      # "|" splits the current window vertically, and "-" splits it horizontally
      unbind '"'
      unbind %
      bind l split-window -h -c "#{pane_current_path}"
      bind h split-window -h -c "#{pane_current_path}"
      bind j split-window -v -c "#{pane_current_path}"
      bind k split-window -v -c "#{pane_current_path}"

      # Pane navigation (vim-like)
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # Pane resizing
      bind -n C-h resize-pane -L 2
      bind -n C-j resize-pane -D 1
      bind -n C-k resize-pane -U 1
      bind -n C-l resize-pane -R 2

      ### other optimization
      # set the shell you like (zsh, "which zsh" to find the path)
      # set -g default-command /bin/zsh
      # set -g default-shell /bin/zsh

      # mouse is great!
      set-option -g mouse on

      # stop auto renaming
      setw -g automatic-rename off
      set-option -g allow-rename off

      # renumber windows sequentially after closing
      set -g renumber-windows on

      # window notifications; display activity on other window
      setw -g monitor-activity on
      set -g visual-activity on
    '';
  };
}
