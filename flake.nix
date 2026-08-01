{
  description = "FreeCAD MCP server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          pythonPackages = pkgs.python3Packages;
        in
        {
          default = pythonPackages.buildPythonApplication {
            pname = "freecad-mcp";
            version = "0.1.21";
            pyproject = true;

            src = self;

            build-system = [ pythonPackages.hatchling ];

            dependencies = [
              pythonPackages.mcp
              pythonPackages.validators
            ];

            pythonImportsCheck = [ "freecad_mcp" ];

            meta = {
              description = "FreeCAD integration through the Model Context Protocol";
              homepage = "https://github.com/neka-nat/freecad-mcp";
              license = pkgs.lib.licenses.mit;
              mainProgram = "freecad-mcp";
            };
          };
        }
      );

      apps = forAllSystems (
        system:
        let
          pkg = self.packages.${system}.default;
        in
        {
          default = {
            type = "app";
            program = "${pkg}/bin/freecad-mcp";
          };

          freecad-mcp = self.apps.${system}.default;
        }
      );
    };
}
