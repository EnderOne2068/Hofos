# Wry — built from SEVERAL translation units and MERGED AT LINK TIME.
#
# The split is not cosmetic.  A language frontend grows fastest in its parser,
# and a single file meant every edit recompiled everything.  It also keeps the
# promise to HISTIC honest: separate compilation is something Histic has to
# handle, so exercising it here is the point rather than a side effect.
CXX      ?= g++
CXXFLAGS ?= -w -Ofast 
OBJS      = wry-lex.o wry-mac.o wry-type.o wry-match.o wry-clos.o wry-core.o wry-parse.o wry-main.o

wry: $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJS) -ldl

%.o: %.cc wry.h
	$(CXX) $(CXXFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) wry
.PHONY: clean
