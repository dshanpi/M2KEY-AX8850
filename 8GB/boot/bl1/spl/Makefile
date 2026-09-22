CUR_PATH        := $(shell pwd)
HOME_PATH       := $(shell pwd)/../../..
BUILD_PATH      := $(HOME_PATH)/build

include $(HOME_PATH)/build/color.mk
include $(HOME_PATH)/build/config.mak
include $(HOME_PATH)/build/version.mak

CC := $(CROSS)gcc
LD := $(CROSS)ld
OBJCOPY := $(CROSS)objcopy
OBJDUMP := $(CROSS)objdump

IMAGE := spl_$(PROJECT).axf
SPL_BIN := spl_$(PROJECT).bin
SPL_SEC_BIN := spl_$(PROJECT)_enc.bin
SPL_SING_BIN := spl_$(PROJECT)_signed.bin
SPL_SEC_SING_BIN := spl_$(PROJECT)_enc_signed.bin

OBJS := ../board/start.o ../common/cmn.o ../core/trace/trace.o \
	../driver/pci/pcie_ep.o ../driver/timer/timer.o spl_main.o \
	../driver/uart/early_printf.o ../driver/uart/uart.o\
	../driver/ddr/ax650x_lpddr4x.o ../driver/ddr/pll_config.o \
	../driver/ddr/board.o  ../driver/efuse/efuse_drv.o

ifeq ($(strip $(SUPPORT_bl1)),TRUE)
OBJS += ../driver/spi/spinor.o ../driver/spi/dw_spi_mst.o
endif

DEPS := $(patsubst %.o,%.d,$(OBJS))

CPPFLAGS := -g -Wall -MMD -MP -fno-builtin
CPPFLAGS +=  -I ../driver/include \
			 -I ../board/include \
			 -I ../common/include \
			 -I ../core/include \
			 -I$(USB_INC)

CPPFLAGS += -D$(CONFIG_PROJECT)=1 -D$(PROJECT)=1
CPPFLAGS += -DSPL_VERSION=\"$(SDK_VERSION)\"
ifneq ($(strip $(AX650_HG4XH08G_H4JA_CHIPS)),)
CPPFLAGS += -DAX650_HG4XH08G_H4JA_CHIPS=$(AX650_HG4XH08G_H4JA_CHIPS)
endif

LDFLAGS  := -g --entry=_start
LDFLAGS  += -T ../board/bl1.lds

ifneq ($(ddr_num),)
CPPFLAGS += -DCFG_DDR_NUM_CMDLINE
CPPFLAGS += -DDDR_NUM=$(ddr_num)
endif

ifneq ($(ddr_clk),)
CPPFLAGS += -DCFG_DDR_CLK_CMDLINE
CPPFLAGS += -DDDR_CFG_$(ddr_clk)=1
endif

.NOTPARALLEL:
all: prepare $(IMAGE)

prepare:
	@python3 $(CUR_PATH)/../tools/load_board_config.py


$(IMAGE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@ -L $(shell dirname `$(CC) $(c_flags) -print-libgcc-file-name`) -lgcc
	$(OBJCOPY) -O binary $(IMAGE) $(SPL_BIN)
	$(OBJDUMP) -D -S -m arm $(IMAGE) > spl.dis

install:
	@$(ECHO) -e $(GREEN)"bl1 fdl $@..." $(DONE)
	@$(ECHO) -e $(GREEN)"bl1 spl $@..." $(DONE)
	@$(MKDIR) $(BUILD_PATH)/out/$(PROJECT)/
	@$(MKDIR) $(BUILD_PATH)/out/$(PROJECT)/images/debug
	$(CP) $(CUR_PATH)/$(SPL_BIN) $(BUILD_PATH)/out/$(PROJECT)/images
	$(CP) $(HOME_PATH)/tools/imgsign/eip.bin $(BUILD_PATH)/out/$(PROJECT)/eip.bin
ifeq ($(strip $(SIGN_USE_RSA3072)),true)
	@python3 $(HOME_PATH)/tools/imgsign/spl_AX650_slave_sign_3072.py -i $(BUILD_PATH)/out/$(PROJECT)/images/$(SPL_BIN) -o $(BUILD_PATH)/out/$(PROJECT)/images/$(SPL_SING_BIN) -pub $(HOME_PATH)/tools/imgsign/key_3072/pubkey.pem -prv $(HOME_PATH)/tools/imgsign/key_3072/private.pem -fw $(HOME_PATH)/tools/imgsign/eip.bin -packsize 0x40000 -cap 0x7efe
	@openssl aes-256-ecb -e -in $(BUILD_PATH)/out/$(PROJECT)/images/$(SPL_BIN) -out $(BUILD_PATH)/out/$(PROJECT)/images/$(SPL_SEC_BIN) -K 95f3f50006070000270050000000000000000000000000000000000000000000 -nosalt -p
	@python3 $(HOME_PATH)/tools/imgsign/spl_AX650_sign_3072.py -i $(BUILD_PATH)/out/$(PROJECT)/images/$(SPL_SEC_BIN) -o $(BUILD_PATH)/out/$(PROJECT)/images/$(SPL_SEC_SING_BIN) -pub $(HOME_PATH)/tools/imgsign/key_3072/pubkey.pem -prv $(HOME_PATH)/tools/imgsign/key_3072/private.pem -fw $(HOME_PATH)/tools/imgsign/eip.bin -packsize 0x40000 -cap 0x7ffe
else
	@openssl aes-256-ecb -e -in $(BUILD_PATH)/out/$(PROJECT)/images/$(SPL_BIN) -out $(BUILD_PATH)/out/$(PROJECT)/images/$(SPL_SEC_BIN) -K 0000000000000000000000000000000000000000000000000000000000000000 -nosalt -p
	@python3 $(HOME_PATH)/tools/imgsign/spl_AX650_slave_sign.py -i $(BUILD_PATH)/out/$(PROJECT)/images/$(SPL_SEC_BIN) -o $(BUILD_PATH)/out/$(PROJECT)/images/$(SPL_SEC_SING_BIN) -pub $(HOME_PATH)/tools/imgsign/public.pem -prv $(HOME_PATH)/tools/imgsign/private.pem -fw $(HOME_PATH)/tools/imgsign/eip.bin -packsize 0x40000 -cap 0x7bfe
	@python3 $(HOME_PATH)/tools/imgsign/spl_AX650_slave_sign.py -i $(BUILD_PATH)/out/$(PROJECT)/images/$(SPL_BIN) -o $(BUILD_PATH)/out/$(PROJECT)/images/$(SPL_SING_BIN) -pub $(HOME_PATH)/tools/imgsign/public.pem -prv $(HOME_PATH)/tools/imgsign/private.pem -fw $(HOME_PATH)/tools/imgsign/eip.bin -packsize 0x40000 -cap 0x27afe
endif

clean:
	rm -rf $(IMAGE) $(OBJS) $(DEPS) $(SPL_BIN)

.PHONY: prepare all clean

-include $(DEPS)
