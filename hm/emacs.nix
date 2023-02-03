{ config, pkgs, lib, stdenv, inputs, ... }: {
  config = {
    home.file.".local/bin/me" = {
      executable = true;
      text = ''
        #!/bin/sh
        exec emacs -Q -nw -l ${../mini-init.el} "$*"
      '';
    };
    xresources.properties = {
      "Emacs*toolBar" = 0;
      "Emacs*menuBar" = 0;
      "Emacs*geometry" = "80x30";
      "Emacs*font" = "Ttyp0";
      "Emacs*scrollBar" = "on";
      "Emacs*scrollBarWidth" = 6;
    };
    services.emacs.enable = lib.mkForce false;
    programs.emacs = {
      enable = config.ao.primaryUser.emacsFromNix;
      extraConfig = ''
         (load-file "${inputs.emacs-d}/init.el")
         (run-hooks (quote after-init-hook))
         (run-hooks (quote emacs-startup-hook))
         (run-hooks (quote window-setup-hook))
      '';
      extraPackages = elpa:
        with elpa; [
          rg
          project
          sly
          sly-asdf
          sly-quicklisp
          sly-repl-ansi-color
          sly-macrostep
          ack
          bash-completion
          better-defaults
          ccls
          c-eldoc
          centered-cursor-mode
          cider
          company
          company-c-headers
          company-posframe
          dash
          dashboard
          default-text-scale
          dired-subtree
          editorconfig
          eldoc
          eldoc-cmake
          elfeed
          elisp-format
          elisp-lint
          elisp-refs
          elisp-slime-nav
          elpher
          emms
          eros
          evil
          evil-collection
          evil-commentary
          evil-exchange
          evil-goggles
          evil-snipe
          exwm
          feebleline
          flycheck
          flymake-cursor
          forge
          fringe-current-line
          geiser-guile
          general
          git-gutter
          go-imports
          guix
          haskell-mode
          hydra
          lispy
          lsp-haskell
          lsp-java
          lsp-metals
          lsp-mode
          lsp-ui
          magit
          marginalia
          writeroom-mode
          nix-mode
          notmuch
          org
          org-bullets
          pdf-tools
          raku-mode
          restart-emacs
          sly
          telega
          undo-fu
          undo-tree
          use-package
          unicode-fonts
          use-package-hydra
          hl-todo
          vertico-posframe
          vterm
          which-key-posframe
          winum
          xenops
          prettify-greek
          flyspell-correct
          flyspell-correct-popup
          rainbow-mode
        ];
    };
  };
}
