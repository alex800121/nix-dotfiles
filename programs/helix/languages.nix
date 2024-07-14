{
  language = [
    {
      name = "haskell";
      scope = "source.haskell";
      injection-regex = "hs|haskell";
      file-types = ["hs" "hls" "hs-boot" "hsc"];
      roots = ["Setup.hs" "stack.yaml" "cabal.project.local" "cabal.project"];
      comment-token = "--";
      block-comment-tokens = { start = "{-"; end = "-}"; };
      language-servers = [ "haskell-language-server" ];
      indent = { unit = "  "; tab-width = 2;};
      diagnostic-severity = "Hint";
      auto-format = true;
    }
    {
      name = "nix";
      auto-format = true;
    }
  ];
}
