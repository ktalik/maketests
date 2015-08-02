# Make Tests
# Konrad Talik <konrad.talik@slimak.matinf.uj.edu.pl>

#/ In order to `make tests', set up following variables:
#/  TEXEC                   target executable
#/
#/ Optional parameters (with default values)
#/  TDDIR=tests             tests default dir
#/  TPARAMS="[INPUT_FILE]"  executable params for all tests
#/  TINPUT=TDDIR            input files root directory
#/  TOUTPUT=TDDIR           expected outputs root directory
#/  TACTUAL=TDDIR           actual outputs root directory
#/  TIN=.in                 test input extension (start with dot if present)
#/  TOUT=.out               expected outputs extension
#/  TACT=.act               actual outputs extension
#/
#/ Available TPARAMS aliases with their meanings (see README.md):
#/  [INPUT_FILE]            full test input file name
#/  [FILE_STEM]             test input/output file stem (name without extension)

###
# Useful variables
###

MAKEFILE_PATH=$(abspath $(lastword $(MAKEFILE_LIST)))

###
# Default constans
###

# maketests is using bash
SHELL=/bin/bash

# Tests default dir
ifeq ($(origin TDDIR), undefined)
TDDIR=tests
endif

ifeq ($(origin TPARAMS), undefined)
TPARAMS="[INPUT_FILE]"
endif

ifeq ($(origin TINPUT), undefined)
TINPUT=$(TDDIR)
endif

ifeq ($(origin TOUTPUT), undefined)
TOUTPUT=$(TDDIR)
endif

ifeq ($(origin TACTUAL), undefined)
TACTUAL=$(TDDIR)
endif

ifeq ($(origin TIN), undefined)
TIN=.in
endif

ifeq ($(origin TOUT), undefined)
TOUT=.out
endif

ifeq ($(origin TACT), undefined)
TACT=.act
endif

INPUTS=$(wildcard $(TINPUT)/*$(TIN))
ACTUALS=$(patsubst %$(TIN), %$(TACT), $(INPUTS))
DIFF=git diff --no-index --no-prefix --ignore-space-change --word-diff=plain

###
# Recipes
###

.PHONY: tests_help
tests_help:
	@grep "^#/" < $(MAKEFILE_PATH) | cut -c4-; exit

# Make Tests
.PHONY: tests
tests:
	@printf "Tests: params check...\n"
	$(MAKE) --silent tests_params_check
	@printf "Tests: start.\n"
	$(MAKE) init_tests
	$(MAKE) --silent run_tests
	@printf "Tests: DONE.\n"
	$(MAKE) --silent sumup_tests
	$(MAKE) --silent tests_status

# Params check
.PHONY: tests_params_check
tests_params_check:
ifeq ($(origin TEXEC), undefined)
	$(error TEXEC: Please provide executable filename/path!)
endif

# Init tests
.PHONY: init_tests
init_tests:
	@echo "Tests: init..."
	for act in $(ACTUALS) ; do \
		rm -f $$act; \
		rm -f "$$act.failed"; \
	done

# Run tests
.PHONY: run_tests
run_tests:
	@echo "Tests: running..."
	@for act in $(ACTUALS) ; do \
		$(MAKE) --silent $$act ; \
	done

# Print summary with exit code
.PHONY: sumup_tests
sumup_tests:
	@echo "Tests summary..."
	@for act in $(ACTUALS) ; do \
		$(MAKE) --silent compare_test \
			act="$$act" \
			out="$${act/$(TACT)/$(TOUT)}" ;\
	done
	@echo

# Return tests status code
.PHONY: tests_status
tests_status:
	@echo "Tests: exiting with tests status..."
	@for act in $(ACTUALS) ; do \
		if [ -a $$act.failed ] ; then exit 2 ; fi ; \
	done

# Test exec with input and compare actuals
.PHONY: %$(TACT)
%$(TACT): %$(TIN) %$(TOUT)
	$(MAKE) --silent run_test \
		params="$(subst [INPUT_FILE], $*$(TIN), $(subst [FILE_STEM], $*, $(TPARAMS)))"\
		act=$@
	$(MAKE) --silent compare_test act="$@" out="$(word 2, $^)" verbose=true

# Test exec with params and create actuals
#
# Parameters:
#   params      executable parameters for run_test
#   act         actual output filename
#   verbose     flag: print run_test description
#
.PHONY: run_test
run_test:
	@if [ -n $(verbose) ] ; then \
		printf "Test: $(TEXEC) $(params)"; \
	fi;
	$(shell $(TEXEC) $(params) > $(act))

# Compare expected outputs and actuals
#
# Parameters:
#   verbose         flag: print statuses as PASSED or FAILED
#                   if ommited, status will have format: . or x respectively
#   silent          flag: do not print any output
#   fail_details    flag: print FAILED tests details
.PHONY: compare_test
compare_test:
	@if [ "$$($(DIFF) $(out) $(act))" == "" ] ; then\
		if [ $(verbose) ] ; then \
			printf " ...\e[0;32mPASSED\e[0m.\n"; \
		    $(DIFF) $(out) $(act); \
		elif [ ! $(silent) ] ; then \
			printf "\e[0;32m.\e[0m"; \
		fi; \
	else \
		if [ "$(verbose)" -o "$(fail_details)"  ] ; then \
			printf " ...\e[0;31mFAILED\e[0m:\n"; \
		    $(DIFF) $(out) $(act); \
		elif [ ! $(silent) ] ; then \
			printf "\e[0;31mx\e[0m"; \
			touch $(act).failed; \
		fi; \
	fi;
