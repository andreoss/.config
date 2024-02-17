{ config, pkgs, lib, stdenv, ... }: {
  imports = [ ../../config.nix ];
  config = {
    programs.mercurial = {
      enable = true;
      userName = config.ao.primaryUser.handle;
      userEmail = config.ao.primaryUser.email;
      package = pkgs.mercurialFull;
    };
    programs.jujutsu = { enable = true; };
    programs.git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      difftastic.enable = true;
      userName = config.ao.primaryUser.handle;
      userEmail = config.ao.primaryUser.email;
      signing = {
        key = config.ao.primaryUser.key;
        signByDefault = true;
      };
      extraConfig = { init = { defaultBranch = "master"; }; };
      aliases = {
        alias = ''!f() { git config --get-regexp "^alias.''${1}$" ;}; f'';
        au = "add -u";
        branch = "branch --sort=-committerdate";
        br = "branch";
        brd = "branch -D";
        cb = "co -b";
        cc = "clone";
        cia = "commit --amend";
        ci = "commit";
        cn = "!f() { git checkout -b \${1} origin/master ; }; f";
        co = "checkout";
        fa = "fetch --all";
        fe = "fetch";
        last = "log -1 HEAD";
        ll = "log --oneline";
        l = "log --graph --oneline --abbrev-commit --decorate=short";
        me = "merge";
        pf = "push --force";
        pl = "pull";
        pode = "pull origin develop";
        poma = "pull origin master";
        ps = "push";
        pufo = "push --force";
        pu = "pull";
        pure = "pull --rebase";
        rede = "pure origin develop";
        rema = "pure origin master";
        ri = "rebase --interactive";
        spull = "!git stash && git pull && git stash pop";
        st = "status --short --branch";
        unstage = "reset HEAD -- ";
        xx = "reset HEAD";
      };
      extraConfig = {
        pull.rebase = false;
        rebase.autosquash = true;
        rerere.enabled = true;
      };
      includes = [{
        path = ../../git/config.work;
        condition = "gitdir:~/work";
      }];
    };
    programs.gh = {
      enable = true;
      settings = {
        aliases = {
          co = "pr checkout";
          pv = "pr view";
          pc = "pr create";
        };
        git_protocol = "ssh";
      };
    };
    home.packages = with pkgs; [
      fossil
      gitAndTools.git-codeowners
      gitAndTools.git-extras
      gitAndTools.gitflow
      git-crypt
      pre-commit
      aspell
      aspellDicts.ru
      aspellDicts.en
      aspellDicts.es
    ];
  };
}
