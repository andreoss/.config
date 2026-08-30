{
  ...
}:
{
  boot.initrd = {
    kernelModules = [
      "ahci"
      "amdgpu"
      "nvme"
      "sd_mod"
      "sr_mod"
      "uas"
      "usbhid"
      "usb_storage"
      "vfio-pci"
      "xhci_pci"
    ];
    verbose = true;
  };
  boot.tmp = {
    useTmpfs = true;
    cleanOnBoot = true;
  };
}
