define Device/glinet_gl-ar300m-nand
  ATH_SOC := qca9531
  DEVICE_TITLE := GL-AR300M (NAND)
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-storage kmod-usb-ledtrig-usbport
  KERNEL_SIZE := 2048k
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  VID_HDR_OFFSET := 512
  IMAGES += factory.ubi
  IMAGE/sysupgrade.bin := sysupgrade-tar
  IMAGE/factory.ubi := append-kernel | pad-to $$$$(KERNEL_SIZE) | append-ubi
endef
#TARGET_DEVICES += glinet_gl-ar300m-nand

define Device/glinet_gl-x300b
   ATH_SOC := qca9531
   DEVICE_TITLE := GL-X300B
   DEVICE_PACKAGES := kmod-usb-core kmod-usb2 kmod-usb-storage kmod-usb-ledtrig-usbport
   KERNEL_SIZE := 2048k
   BLOCKSIZE := 128k
   PAGESIZE := 2048
   VID_HDR_OFFSET := 2048
   IMAGES += factory.ubi
   IMAGE/sysupgrade.bin := sysupgrade-tar
   IMAGE/factory.ubi := append-kernel | pad-to $$$$(KERNEL_SIZE) | append-ubi
endef
TARGET_DEVICES += glinet_gl-x300b

define Device/glinet_gl-ar750s-nor-nand
   ATH_SOC := qca9563
   DEVICE_TITLE := GL-AR750S (NOR/NAND)
   DEVICE_PACKAGES := kmod-ath10k-ct-htt ath10k-firmware-qca9887-ct-htt kmod-usb-core \
	kmod-usb2 kmod-usb-storage
   KERNEL_SIZE := 2048k
   BLOCKSIZE := 128k
   PAGESIZE := 2048
   VID_HDR_OFFSET := 2048
   IMAGES += factory.img
   IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
   IMAGE/factory.img := append-kernel | pad-to $$$$(KERNEL_SIZE) | append-ubi
   SUPPORTED_DEVICES += gl-ar750s glinet,gl-ar750s glinet,gl-750s-nor glinet,gl-750s-nor-nand
endef
TARGET_DEVICES += glinet_gl-ar750s-nor-nand
