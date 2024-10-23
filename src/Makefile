SUB_DIRECTORIES=elm

.PHONY: all ${SUB_DIRECTORIES}


all: ${SUB_DIRECTORIES}
	@echo finished
	@echo $<

${SUB_DIRECTORIES}:
	${MAKE} -C $@

