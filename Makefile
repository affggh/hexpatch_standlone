CC = clang
CXX = clang++

override CXXFLAGS := $(CXXFLAGS) -std=c++17 -Wall

HEXPATCH_SRC = hexpatch.cpp

obj/%.o: %.cpp
	@mkdir -p `dirname $@`
	@echo -e "\t    CPP\t    $@"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

.PHONY: all

all: bin/hexpatch bin/hexpatch_static

bin/hexpatch:
	@mkdir -p `dirname $@`
	@echo -e "\t    LD\t    $@"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) $^ -o $@ $(LDFLAGS)
	@echo -e "\t    STRIP\t    $@"
	@$(STRIP) $(STRIPFLAGS) $@

bin/hexpatch_static:
	@mkdir -p `dirname $@`
	@echo -e "\t    LD\t    $@"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) $^ -o $@ $(LDFLAGS)
	@echo -e "\t    STRIP\t    $@"
	@$(STRIP) $(STRIPFLAGS) $@
