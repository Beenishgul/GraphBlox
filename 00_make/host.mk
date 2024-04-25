#!make
# =========================================================
# Starting point of GraphBlox generate IPs and compile Host
# =========================================================
.PHONY: start
start:
	$(ECHO) "========================================================="
	$(ECHO) "${RED}Initial compile will only take a minute!${NC}"
	$(ECHO) "========================================================="
	-@$(MAKE) start $(MAKE_DEVICE)
	-@$(MAKE) start $(MAKE_HOST)
	$(ECHO) "========================================================="
	$(ECHO) "${YELLOW}Usage : make help -- to view options!${NC}"
	$(ECHO) "========================================================="
# =========================================================

.PHONY: host
host:
	$(ECHO) "========================================================="
	$(ECHO) "${RED}[HOST] Initial compile will only take a minute!${NC}"
	$(ECHO) "========================================================="
	-@$(MAKE) start $(MAKE_HOST)
	$(ECHO) "========================================================="
	$(ECHO) "${YELLOW}Usage : make help -- to view options!${NC}"
	$(ECHO) "========================================================="
# =========================================================

# =========================================================
# Compile all steps
# =========================================================
.PHONY: all
all:
	-@$(MAKE) all $(MAKE_DEVICE)
	-@$(MAKE) all $(MAKE_HOST)
	
.PHONY: clean-all
clean-all:
# 	-@$(MAKE) clean-all $(MAKE_DEVICE)
# 	-@$(MAKE) clean-all $(MAKE_HOST)
	$(PYTHON) $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(UTILS_DIR)/$(UTILS_PYTHON)/make_clean_all.py $(ROOT_DIR)/$(APP_DIR) $(ROOT_DIR)/$(APP_DIR)/.gitignore
	
.PHONY: clean
clean:
	-@$(MAKE) clean $(MAKE_DEVICE)
	-@$(MAKE) clean $(MAKE_HOST)
	
.PHONY: clean-results
clean-results:
	-@$(MAKE) clean-results $(MAKE_HOST)

.PHONY: help
help:
	-@$(MAKE) help $(MAKE_DEVICE)
	-@$(MAKE) help $(MAKE_HOST)
# =========================================================

# =========================================================
# Run GraphBlox HOST
# =========================================================
.PHONY: run
run:
	-@$(MAKE) run $(MAKE_HOST) 
	
.PHONY: debug-memory
debug-memory:
	-@$(MAKE) debug-memory $(MAKE_HOST) 

.PHONY: debug
debug:
	-@$(MAKE) debug $(MAKE_HOST) 
# =========================================================

# =========================================================
# Run Tests HOST
# =========================================================
.PHONY: run-test
run-test:
	-@$(MAKE) run-test $(MAKE_HOST) 

.PHONY: debug-test
debug-test:
	-@$(MAKE) debug-test $(MAKE_HOST) 

.PHONY: debug-test-memory
debug-test-memory:
	-@$(MAKE) debug-test-memory $(MAKE_HOST)

.PHONY: test
test:
	-@$(MAKE) test $(MAKE_HOST)
# =========================================================