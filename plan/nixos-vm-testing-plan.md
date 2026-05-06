# NixOS VM Testing Environment Plan

## Overview
Create an isolated VM environment for testing NixOS configuration changes from the dotfiles repository.

## Context
- **Repository**: dotfiles with NixOS configurations (nixos-config/, home-manager/)
- **Current setup**: Flake-based configuration with NixOS unstable, home-manager
- **Host**: The user's main NixOS machine
- **Goal**: Test configuration changes in an isolated VM before applying to host

---

## Recommended VM Software

### Primary: Quickemu (Recommended for ease)
- **Why**: Wrapper around QEMU that simplifies VM creation, excellent NixOS support
- **Cost**: Free and open source
- **Installation**: nix profile install github:quickemu-project/quickemu
- **Requirements**: Requires KVM support (available on most Linux systems)

### Alternative: QEMU/KVM direct
- **Why**: Native to NixOS ecosystem, best performance
- **Cost**: Free and open source
- **Installation**: Already in nixpkgs

### Alternative: VirtualBox
- **Why**: User-friendly, widely used
- **Cost**: Free (Oracle VirtualBox)
- **Cons**: Slower than QEMU, less integrated with Nix tooling

---

## Implementation Steps

### Step 1: Install VM Software

**Quickemu (Recommended)**:
```bash
# Install via Nix
nix profile install github:quickemu-project/quickemu

# Verify installation
quickemu --version
```

### Step 2: Create Test VM Configuration

Create hosts/test-vm/default.nix:

```nix
# hosts/test-vm/default.nix
{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    ../../nixos-config/configuration.nix
  ];

  # Override hardware-specific settings
  hardware = {
    enableRedistributableFirmware = lib.mkForce false;
    enablePCIBusIdMapping = lib.mkForce true;
  };

  # Disable hardware-specific services
  services = {
    thermald.enable = lib.mkForce false;
  };

  # VM settings
  virtualisation = {
    memorySize = 4096;
    cores = 2;
    diskSize = 20 * 1024;
    # Enable port forwarding for SSH
    forwardPorts = [ { from = "host"; host.port = 2222; guest.port = 22; } ];
  };

  # SSH access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PermitEmptyPasswords = true;
    };
  };

  # Root password for testing
  users.users.root.password = "test";
}
```

### Step 3: Add Test VM to Flake Outputs

Create hosts/test-vm/flake-module.nix:

```nix
# hosts/test-vm/flake-module.nix
{ inputs, lib, ... }:

{
  nixosConfigurations.test-vm = lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [ ./default.nix ];
  };
}
```

Update flake.nix to import the new module:

```nix
# In flake.nix - add to imports array
imports = [
  ./hosts/orbiter/flake-module.nix
  ./hosts/test-vm/flake-module.nix  # Add this
];
```

### Step 4: Build and Run the VM

**Method 1 - Using Nix run (Recommended)**:
```bash
# Build and run interactive VM
nix run .#nixosConfigurations.test-vm.config.system.build.vm

# Or build only, then run
nix build .#nixosConfigurations.test-vm.config.system.build.vm
./result/bin/run-nixos-vm
```

**Method 2 - Using Quickemu**:
```bash
# Download NixOS ISO
quickget nixos unstable

# Create VM configuration
cat > nixos-test-vm.conf << 'EOF'
os="nixos"
iso="nixos-unstable-x86_64-linux.iso"
disk_size="20G"
memory="4G"
cores="2"
boot="uefi"
EOF

# Create and start VM
quickemu --vm nixos-test-vm.conf
```

### Step 5: Test Configuration Changes in VM

Once the VM is running:

**Option A - Clone dotfiles in VM (Recommended)**:
```bash
# In VM terminal - clone your dotfiles
git clone https://github.com/yourusername/dotfiles.git /root/dotfiles
cd /root/dotfiles

# Test NixOS configuration
sudo nixos-rebuild switch --flake .#test-vm

# Test home-manager configuration  
home-manager switch --flake .#homeConfigurations.test-vm
```

**Option B - Use GitHub URL**:
If you've pushed your dotfiles to GitHub, in the VM:
```bash
sudo nixos-rebuild switch --flake github:yourusername/dotfiles#test-vm
```

**Option C - SSH access**:
From host, SSH into the running VM:
```bash
ssh -p 2222 root@localhost
# Password: test
```

---

## Complete Workflow

1. **Make changes** to nixos-config/ or home-manager/ in dotfiles
2. **Push to GitHub** (if using Option B)
3. **Build and run test VM**:
   ```bash
   nix run .#nixosConfigurations.test-vm.config.system.build.vm
   ```
4. **In VM terminal**:
   ```bash
   git clone <your-repo> ~/dotfiles
   cd ~/dotfiles
   sudo nixos-rebuild switch --flake .#test-vm
   ```
5. **Verify** changes work as expected
6. **Apply to host** when satisfied:
   ```bash
   sudo nixos-rebuild switch --flake .#orbiter
   ```

---

## Advanced: Automated Testing with runNixOSTest

For automated CI-style tests, create test.nix:

```nix
# test.nix
let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.testers.runNixOSTest {
  name = "config-test";

  nodes.machine = { config, pkgs, ... }: {
    imports = [ ./nixos-config/configuration.nix ];
    virtualisation.memorySize = 2048;
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("nix --version")
    # Add custom test assertions here
  '';
}
```

Run:
```bash
nix-build test.nix
./result/bin/nixos-test-driver
```

---

## Helper Script

Create bin/test-nixos-vm:

```bash
#!/usr/bin/env bash
set -e

echo "Building NixOS test VM..."
nix build .#nixosConfigurations.test-vm.config.system.build.vm --show-trace

echo "Launching VM..."
exec ./result/bin/run-nixos-vm
```

Make executable:
```bash
chmod +x bin/test-nixos-vm
```

Usage:
```bash
./bin/test-nixos-vm
```

---

## Summary

| Component | Recommendation |
|-----------|----------------|
| VM Software | Quickemu (easiest) or QEMU/KVM |
| VM Access | SSH port 2222, or console |
| Config Sync | Clone dotfiles in VM |
| Testing | Interactive VM |
| Isolation | Full VM isolation |

---

## Requirements Checklist

- [ ] KVM/VT-x hardware virtualization enabled in BIOS
- [ ] Quickemu installed
- [ ] Test VM config added to flake
- [ ] 20GB+ free disk space
- [ ] Network access for ISO download

---

## Notes

- Test VM uses nixos-unstable like the host
- Home-manager configs testable in VM
- VM is ephemeral - rebuild for clean state
- For CI, see nix-vm-test from numtide
