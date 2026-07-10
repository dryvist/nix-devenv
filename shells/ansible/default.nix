# Ansible Configuration Management Shell
#
# Minimal Ansible-only environment for configuration management repositories.
# No Terraform/Packer overhead - focused on Ansible, linting, and testing.
{
  pkgs,
  extraPackages ? [ ],
  extraPythonPackages ? (_: [ ]),
}:
let
  # One python env carrying ansible AND its library deps. Ansible executes
  # implicit-localhost modules with its own sys.executable — a separate
  # python3.withPackages env on PATH is invisible to those tasks, so
  # amazon.aws (S3 inventory resolvers) silently loses boto3 unless the
  # interpreter that runs ansible itself can import it.
  ansiblePython = pkgs.python3.withPackages (
    ps:
    (with ps; [
      ansible # full package: bundles community collections (amazon.aws etc.)
      paramiko
      jsondiff
      pyyaml
      jinja2
      # botocore is listed explicitly — not left to boto3's propagation — so
      # the native amazon.aws S3 path keeps working if that ever changes.
      boto3
      botocore
    ])
    ++ (extraPythonPackages ps)
  );
in
pkgs.mkShell {
  buildInputs =
    with pkgs;
    [
      # === Configuration Management ===
      # ansible-playbook/ansible come from ansiblePython (via ansible-core
      # propagation) so localhost tasks run on the boto3-capable interpreter.
      ansiblePython
      ansible-lint
      molecule

      # === Secrets Management ===
      sops
      age

      # === Testing ===
      bats # Bash Automated Testing System — moved from nix-home global env (project-scoped tool)

      # === Utilities ===
      jq
      yq
      pre-commit
    ]
    ++ extraPackages;

  shellHook = ''
    if [ -z "''${DIRENV_IN_ENVRC:-}" ]; then
      echo "═══════════════════════════════════════════════════════════════"
      echo "Ansible Configuration Management Environment"
      echo "═══════════════════════════════════════════════════════════════"
      echo ""
      echo "Configuration Management:"
      echo "  - ansible: $(ansible --version 2>/dev/null | head -1)"
      echo "  - ansible-lint: $(ansible-lint --version 2>/dev/null)"
      echo "  - molecule: $(molecule --version 2>/dev/null)"
      echo ""
      echo "Secrets Management:"
      echo "  - sops: $(sops --version 2>/dev/null)"
      echo "  - age: $(age --version 2>/dev/null)"
      echo ""
      echo "Getting Started:"
      echo "  1. Install collections: ansible-galaxy install -r requirements.yml"
      echo "  2. Setup pre-commit: pre-commit install"
      echo "  3. Run playbook: ansible-playbook -i inventory/hosts.yml playbooks/site.yml"
      echo ""
    fi
  '';
}
