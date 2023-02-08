with import <nixpkgs> { };

mkShell {
  packages = [
    inotify-tools
    nodePackages.tailwindcss
    nodePackages."@tailwindcss/language-server"
  ];
}
