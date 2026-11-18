{
  description = "ghost: Inject hidden IDE and AI workspace configs cleanly";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        templatesDir = ./templates;
        hasTemplates = builtins.pathExists templatesDir;

        templateNames =
          if hasTemplates then
            builtins.attrNames (
              lib.filterAttrs (_: type: type == "directory") (builtins.readDir templatesDir)
            )
          else
            [ ];

        mkDotApp = name:
          let
            app = pkgs.writeShellApplication {
              name = "inject-${name}";
              text = ''
                target_dir=".${name}"
                source_dir="${templatesDir}/${name}"

                if [ ! -d "$source_dir" ] || [ -z "$(ls -A "$source_dir")" ]; then
                  echo "[ghost] Skipping $target_dir: template directory is empty."
                  exit 0
                fi

                mkdir -p "$target_dir"
                cp -r "$source_dir"/* "$target_dir/"
                chmod -R u+w "$target_dir"

                if [ -f .gitignore ] && ! grep -qxF "$target_dir/" .gitignore; then
                  echo "$target_dir/" >> .gitignore
                fi

                echo "[ghost] Injected $target_dir/ and added to .gitignore"
              '';
            };
          in
          {
            type = "app";
            program = "${app}/bin/inject-${name}";
          };

        individualApps = lib.genAttrs templateNames mkDotApp;

        injectAllApp = pkgs.writeShellApplication {
          name = "inject-all";
          text =
            if templateNames == [ ] then
              ''echo "No templates found in ./templates"''
            else
              lib.concatMapStringsSep "\n" (name: "${individualApps.${name}.program}") templateNames;
        };
      in
      {
        apps = individualApps // {
          all = {
            type = "app";
            program = "${injectAllApp}/bin/inject-all";
          };
          default = {
            type = "app";
            program = "${injectAllApp}/bin/inject-all";
          };
        };
      }
    );
}
