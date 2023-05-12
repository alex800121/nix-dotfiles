self: super: let
  nvim-web-devicons = super.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-web-devicons";
    version = "2023-05-01";
    src = super.fetchFromGitHub {
      owner = "nvim-tree";
      repo = "nvim-web-devicons";
      rev = "nerd-v2-compat";
      sha256 = "sha256-dYiG5uBSBU0b5MMZp6xKd8gB79nNdHGuq2UfcWnv2Es=";
    };
    meta.homepage = "https://github.com/nvim-tree/nvim-web-devicons/";
  };
in {
  vimPlugins = super.vimPlugins // {
    inherit nvim-web-devicons;
  };
}
