{ config, lib, pkgs, ... }:

let
  rocmPkgs = with pkgs; [ rocblas hipblas clr ];
in
{
  options.my.hardware.gpu = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable AMD GPU support with ROCm.";
    };

    type = lib.mkOption {
      type = lib.types.enum [ "amd" "intel" "nvidia" ];
      default = "amd";
      description = "GPU vendor to configure.";
    };
  };

  config = lib.mkIf config.my.hardware.gpu.enable (lib.mkMerge [
    (lib.mkIf (config.my.hardware.gpu.type == "amd") {
      boot.initrd.kernelModules = [ "amdgpu" ];

      hardware.graphics.extraPackages = with pkgs; [
        vulkan-loader
        vulkan-headers
        mesa
        rocmPackages.clr.icd
      ];

      environment.sessionVariables = {
        VK_ICD_FILENAMES =
          "/run/opengl-driver/etc/vulkan/icd.d/radeon_icd.x86_64.json";
      };

      systemd.tmpfiles.rules = [
        "L+     /opt/rocm   -    -    -    -    ${pkgs.symlinkJoin { name = "rocm"; paths = rocmPkgs; }}"
      ];
    })

    (lib.mkIf (config.my.hardware.gpu.type == "intel") {
      hardware.graphics.extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
      ];
    })
  ]);
}