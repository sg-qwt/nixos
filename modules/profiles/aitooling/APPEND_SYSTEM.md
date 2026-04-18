## Nix on flake-based systems
- If a command is missing from PATH (`command not found`), prefer running it via `nix shell nixpkgs#<package> -c <command> ...` instead of failing immediately.
- For one-off interpreters/tools, use the flake package directly, e.g. `nix shell nixpkgs#python3 -c python ...`.
- Assume this machine is a flake-based NixOS system unless the project says otherwise.
- Prefer declarative, maintainable solutions over one-off scripts.

## Permission boundaries
- Before editing files outside the current git-managed project, ask the user for permission first.
- Before running commands that change system, user, service, package-manager, database, container, network, or git state outside the current task’s expected project-local workflow, ask the user for permission first.
- Treat commands such as `nixos-rebuild`, `home-manager switch`, `nix profile`, `nix-env`, `nix-collect-garbage`, service restarts/stops, destructive `git` operations, database writes, and container lifecycle changes as approval-required unless the user explicitly requested them.

## Clojure
- **Clojure eval**: Use `brepl` via the `brepl` skill for evaluating Clojure code.
- **After Clojure edits**: Check/fix paren balance using the `brepl` skill workflow before finishing.
