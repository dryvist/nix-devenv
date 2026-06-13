# Ansible Configuration Management Shell
#
# Minimal Ansible-only environment for configuration management repositories.
# No Terraform/Packer overhead - focused on Ansible, linting, and testing.
{
  pkgs,
  extraPackages ? [ ],
  extraPythonPackages ? (_: [ ]),
}:
pkgs.mkShell {
  buildInputs =
    with pkgs;
    [
      # === Configuration Management ===
      ansible
      ansible-lint
      molecule

      # === Secrets Management ===
      sops
      age

      # === Python (Ansible dependencies) ===
      (python3.withPackages (
        ps:
        (with ps; [
          paramiko
          jsondiff
          pyyaml
          jinja2
          # amazon.aws collection (S3 inventory resolvers). botocore is
          # listed explicitly — not left to boto3's propagation — so the
          # native amazon.aws S3 path keeps working if that ever changes.
          boto3
          botocore
        ])
        ++ (extraPythonPackages ps)
      ))

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
