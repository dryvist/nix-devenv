# Server administration shell — Linux-only extras
#
# Composes server-admin (cross-platform) via inputsFrom, then adds
# Linux-only block storage, NIC, and TFTP tooling.
{
  pkgs,
  extraPackages ? [ ],
}:
let
  base = import ../server-admin/default.nix { inherit pkgs; };
in
pkgs.mkShell {
  inputsFrom = [ base ];
  buildInputs =
    with pkgs;
    [
      # === Block storage / disk (Linux kernel interfaces) ===
      nvme-cli # NVMe inspection, firmware, format, secure erase
      hdparm # HDD/SSD params, secure erase, USB-stick prep
      sg3_utils # SCSI/SAS HBA utilities (sg_inq, sg_format, sg_logs)

      # === Network (Linux-specific) ===
      ethtool # NIC capabilities, speed/duplex, ring buffers

      # === TFTP server (Linux-only alternative to dnsmasq built-in) ===
      tftp-hpa # standalone in.tftpd server
      atftp # alternative TFTP client/server
    ]
    ++ extraPackages;

  shellHook = ''
    if [ -z "''${DIRENV_IN_ENVRC:-}" ]; then
      echo "═══════════════════════════════════════════════════════════════"
      echo "Server Administration Environment (Linux extras)"
      echo "═══════════════════════════════════════════════════════════════"
      echo ""
      echo "Includes all tools from server-admin plus Linux-only:"
      echo "  nvme-cli, hdparm, sg3_utils, ethtool, tftp-hpa, atftp"
      echo ""
      echo "BMC / IPMI:"
      echo "  ipmitool -I lanplus -H <idrac_ip> -U root -P <pw> chassis status"
      echo "  ipmitool -I lanplus -H <idrac_ip> -U root -P <pw> sol activate"
      echo ""
      echo "racadm (no local client — run via SSH):"
      echo "  ssh root@<idrac_ip> racadm getsysinfo"
      echo ""
    fi
  '';
}
