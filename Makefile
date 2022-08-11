BRANCH?=	$(shell git rev-parse --abbrev-ref HEAD)

all:

test:		
	@[ "$(BRANCH)" = "master" -o "$(BRANCH)" = "" ] \
	    || { [ -f "$(BRANCH)/Makefile" ] && (echo "Testing $(BRANCH)" && cd $(BRANCH) && make -s test) } \
	    || { (echo "$(BRANCH)" | grep -q project) && .scripts/check.py; }
