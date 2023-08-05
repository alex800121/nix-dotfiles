self: super: let
  transparent-nvim = super.vimUtils.buildVimPluginFrom2Nix {
    pname = "transparent-nvim";
    version = "2023-07-06";
    src = super.fetchFromGitHub {
      owner = "xiyaowong";
      repo = "transparent.nvim";
      rev = "f6a0f8387fbea5fbc2b78137444a9de4fdd02459";
      sha256 = "sha256-X0wkLD2XjhP64micSU76SYVx8uWMsQp525k/WkcKDeM=";
    };
    meta.homepage = "https://github.com/xiyaowong/transparent.nvim/";
  };
in {
  vimPlugins = super.vimPlugins // {
    inherit transparent-nvim;
  };
}
