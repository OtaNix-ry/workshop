{
  programs.git = {
    enable = true;
    settings = {
      user.name = "langsjo";
      user.email = "104687438+langsjo@users.noreply.github.com";

      aliases = {
        co = "checkout";
      };

      init.defaultBranch = "main";
      core.editor = "nvim";
      pull.rebase = true;
    };
  };
}
