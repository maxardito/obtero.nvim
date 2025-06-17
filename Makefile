TEST = test/obtero
# This is where you have plenary installed locally. Override this at runtime if yours is elsewhere.
PLENARY = ~/.local/share/nvim/lazy/plenary.nvim/
MINIDOC = ~/.local/share/nvim/lazy/mini.doc/

.PHONY : all
all : style test

.PHONY : test
test :
	PLENARY=$(PLENARY) nvim \
		--headless \
		--noplugin \
		-u test/minimal_init.vim \
		-c "PlenaryBustedDirectory $(TEST) { minimal_init = './test/minimal_init.vim' }"

.PHONY : style
style :
	stylua --check .

.PHONY : version
version :
	@nvim --headless -c 'lua print("v" .. require("obtero").VERSION)' -c q 2>&1
