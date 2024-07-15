############################################################
####                 Common Information                 ####
############################################################

RPI_VERSION ?= 4b

############################################################
####                   Target Options                   ####
############################################################

TARGET_IMAGE ?= kernel8.img
TARGET_ARCH  ?= bcm2711
TARGET_PLAT  ?= $(RPI_VERSION)
TARGET_DIR   ?=  

############################################################
####                    Directories                     ####
############################################################

BUILD_DIR   = build
INCLUDE_DIR = include
SRC_DIR     = arch/$(TARGET_ARCH) \
			  platform/$(TARGET_PLAT) \
			  targets/$(TARGET_DIR) \
			  drivers

############################################################
####                  Compiler Options                  ####
############################################################

CROSS_COMPILE ?= aarch64-linux-gnu

CC		= $(CROSS_COMPILE)-gcc
LD		= $(CROSS_COMPILE)-ld
OBJCOPY	= $(CROSS_COMPILE)-objcopy

LDFLAGS   =
CFLAGS    = -Wall -nostdlib -nostartfiles -ffreestanding -mgeneral-regs-only
CFLAGS   += -I$(INCLUDE_DIR)
ASMFLAGS  = -I$(INCLUDE_DIR)
MACROS    = -DTARGET_ARCH=$(TARGET_ARCH) \
			-DTARGET_PLAT=$(TARGET_PLAT) \

############################################################
####                    Source Files                    ####
############################################################

LSCRIPT = arch/$(TARGET_ARCH)/lscript.ld

SRCS  = $(shell find $(SRC_DIR) -name '*.c')
ASMS  = $(shell find $(SRC_DIR) -name '*.S')
OBJS  = $(addprefix $(BUILD_DIR)/,$(SRCS:%.c=%.c.o))
OBJS += $(addprefix $(BUILD_DIR)/,$(ASMS:%.S=%.s.o))
ELF   = $(BUILD_DIR)/$(TARGET_IMAGE:%.img=%.elf)

############################################################
####                       Build                        ####
############################################################

all: build $(TARGET_IMAGE)

SUB_DIR = $(dir $(SRCS) $(ASMS)) 
MK_DIR  = $(addprefix $(BUILD_DIR)/,$(SUB_DIR))

build:
	@mkdir -p $(MK_DIR)

$(TARGET_IMAGE): $(LSCRIPT) $(OBJS)
	$(LD) -T $(LSCRIPT) -o $(ELF) $(OBJS)
	$(OBJCOPY) $(ELF) -O binary $(TARGET_IMAGE)

$(BUILD_DIR)/%.c.o: %.c
	$(CC) $(CFLAGS) $(MACROS) -c $< -o $@

$(BUILD_DIR)/%.s.o: %.S
	$(CC) $(ASMFLAGS) $(MACROS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR) $(TARGET_IMAGE)

tags:
	@ctags -R
