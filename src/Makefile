RPN_SRCS = fupdate.rpn
SRCS = update.s readrom16.s writerom16.s
OBJS = $(RPN_SRCS:%.rpn=%.o) $(SRCS:%.s=%.o)
MOD = clilup.mod

all: $(MOD)

%.o: %.rpn
	rpncomp -l --no-fat $<

%.o: %.s
	asnut --cpu=newt -g -l $<

$(MOD): $(OBJS) linker.scm clilup.moddesc
	lnnut -g $(OBJS) --list-file=linker.lst linker.scm clilup.moddesc
	modtool --no-extract-module-export --no-extract-module-descriptor $(MOD)

clean:
	-rm $(OBJS) $(MOD)
