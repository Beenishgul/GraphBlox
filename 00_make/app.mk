#!make
MAKE_DIR = 00_make

include ./$(MAKE_DIR)/app.env
export

include ./$(MAKE_DIR)/params.mk
include ./$(MAKE_DIR)/host.mk
include ./$(MAKE_DIR)/device.mk


