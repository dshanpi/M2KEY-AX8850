PRJ_HOME_PATH   := $(abspath $(shell pwd)/..)
PRJ_BUILD_PATH  := $(PRJ_HOME_PATH)/build

SUPPORT_bl1     := TRUE
SUPPORT_RAMDISK := TRUE
SUPPORT_OPTEE   := false
GEN_PAC         := TRUE
SUPPORT_DEB_X86     := FALSE
SUPPORT_DEB_ARM64   := FALSE
SUPPORT_DEB_RISCV   := FALSE
SUPPORT_DEB_LOONGARCH64 := FALSE
SUPPORT_DEB_LOONGARCH64OD := FALSE
SUPPORT_RPM_X86     := FALSE
SUPPORT_RPM_ARM64   := FALSE
SUPPORT_RPM_RISCV   := FALSE
SUPPORT_RPM_LOONGARCH64 := FALSE
SUPPORT_DEB_AX650   := TRUE

# linux OS memory config
# OS:RAMDISK:CMM
OS_MEM         := mem=1152M
# cmm memory config
CMM_POOL_PARAM := anonymous,0,0x148000000,15232M
# dsp mempory config

# if build with asan=yes or debugkconfig=yes, change OS memory to 3GB
ifneq ($(findstring yes, $(asan) $(debugkconfig)),)
OS_MEM         := mem=3072M
CMM_POOL_PARAM := anonymous,0,0x240000000,3072M
endif

# if you want use ubuntu rootfs, uncomment the statement below
# use_ubuntu_rootfs := yes

# Dedicated HG4XH08G-H4JA 2 x 8 GiB bring-up build, 3200 MT/s.
AX650_HG4XH08G_H4JA_CHIPS := 2
