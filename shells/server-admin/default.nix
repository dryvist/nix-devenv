# Server administration shell — cross-platform BMC/IPMI tooling
#
# Use for: iDRAC firmware updates, OS installs via PXE, BIOS/RAID config,
# Serial-over-LAN, VNC to iDRAC Enterprise, network diagnostics.
#
# racadm: not in nixpkgs (Dell vendor RPM, Linux-only). Run via SSH instead:
#   ssh root@<idrac> 'racadm getsysinfo'
{
  pkgs,
  extraPackages ? [ ],
}:
pkgs.mkShell {
  buildInputs =
    with pkgs;
    [
      # === BMC / IPMI ===
      ipmitool # IPMI client + Serial-over-LAN (sol activate)
      freeipmi # ipmiconsole, bmc-config, ipmi-sel

      # === VNC client (iDRAC Enterprise / iLO Advanced) ===
      tigervnc # vncviewer

      # === Serial console ===
      picocom # lightweight serial terminal
      minicom # menu-driven classic
      tio # modern with reconnect and autocomplete

      # === Network boot / TFTP server ===
      dnsmasq # DHCP + TFTP for PXE staging (cross-platform)

      # === ISO / firmware ===
      xorriso # ISO creation/manipulation (also -as mkisofs)
      libisoburn # companion to xorriso
      cabextract # extract Dell firmware .exe / .cab bundles

      # === Network diagnostics ===
      nmap
      tcpdump
      mtr
      iperf3
      wakeonlan

      # === Hardware monitoring ===
      smartmontools # smartctl — run over SSH to a live server

      # === Automation ===
      expect
      sshpass
    ]
    ++ extraPackages;

  shellHook = ''
    if [ -z "''${DIRENV_IN_ENVRC:-}" ]; then
      echo "═══════════════════════════════════════════════════════════════"
      echo "Server Administration Environment"
      echo "═══════════════════════════════════════════════════════════════"
      echo ""
      echo "BMC / IPMI:"
      echo "  ipmitool -I lanplus -H <idrac_ip> -U root -P <pw> chassis status"
      echo "  ipmitool -I lanplus -H <idrac_ip> -U root -P <pw> sol activate"
      echo ""
      echo "racadm (no local client — run via SSH):"
      echo "  ssh root@<idrac_ip> racadm getsysinfo"
      echo "  ssh root@<idrac_ip> racadm getsel"
      echo ""
      echo "iDRAC6 Virtual Console:"
      echo "  Open https://<idrac_ip> → Launch Virtual Console → .jnlp"
      echo "  Requires OpenWebStart (brew install --cask openwebstart)"
      echo ""
    fi
  '';
}
