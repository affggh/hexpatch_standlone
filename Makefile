CC = clang
CXX = clang++
STRIP = llvm-strip
SHELL = bash

override CXXFLAGS := $(CXXFLAGS) -std=c++17 -Wall

HEXPATCH_SRC = hexpatch.cpp
HEXPATCH_OBJ = $(patsubst %.cpp,obj/%.o,$(HEXPATCH_SRC))

obj/%.o: %.cpp
	@mkdir -p `dirname $@`
	@echo -e "\tCPP\t$@"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

.PHONY: all

all: bin/hexpatch bin/hexpatch_static

bin/hexpatch: $(HEXPATCH_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\tLD\t$@"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) $^ -o $@ $(LDFLAGS)
	@echo -e "\tSTRIP\t$@"
	@$(STRIP) $(STRIPFLAGS) $@

bin/hexpatch_static: $(HEXPATCH_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\tLD\t$@"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) $^ -o $@ $(LDFLAGS)
	@echo -e "\tSTRIP\t$@"
	@$(STRIP) $(STRIPFLAGS) $@

clean:
	@echo -e "\tRM\tobj"
	@rm -rf obj
	@echo -e "\tRM\tbin"
	@rm -rf bin
