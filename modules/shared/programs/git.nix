{ config, pkgs, lib, ... }:

let name = "Bassim Shahidy";
    email = "bassim101@gmail.com"; in
{
  lazygit = {
    enable = true;
    settings = {
      os.editPreset = "nvim";
      git.paging.pager = "delta --dark --paging=never";
    };
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = name;
    userEmail = email;
    signing = { 
      key = "~/.ssh/id_github";
      signByDefault = true;
    };
    lfs.enable = true;
    # setting `delta.enable = true;` sets 
    #   `core.pager = "delta"` and
    #   `interactive.diffFilter = "delta --color-only";`
    # by default, so they don't need to be set manually
    delta.enable = true;
    delta.options = {
      line-numbers = true;
      side-by-side = true;
      navigate = true;
    };
    extraConfig = {
      gpg.format = "ssh";
      init.defaultBranch = "main";
      core = {
	      editor = "nvim";
        autocrlf = "input";
      };
      pull.rebase = true;
      rebase.autoStash = true;
      rerere.enabled = true;
      merge.conflictsyle = "diff3";
      diff.colorMoved = "default";
    };
    aliases = {
      a = "add .";
      c = "commit";
      ca = "commit -a";
      cam = "commit -a --amend --no-edit";
      f = "fetch";
      pl = "pull";
      p = "push";
      pf = "push --force-with-lease origin";
      update-last-commit = "!git commit -a --amend --no-edit && git push --force-with-lease origin";
    };
  };

  gh = {
      enable = true;
      gitCredentialHelper = {
        enable = true;
        hosts = ["https://github.com" "https://gist.github.com"];
    };
  };
}