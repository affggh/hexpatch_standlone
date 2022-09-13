CC = clang
CXX = clang++

override CXXFLAGS := $(CXXFLAGS) -std=c++17 -Wall

HEXPATCH_SRC = hexpatch.cpp
HEXPATCH_OBJ = $(patsubst %.cpp,obj/%.o,$(HEXPATCH_SRC))

obj/%.o: %.cpp
	@mkdir -p `dirname $@`
	@echo -e "\t    CPP\t    $@"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

.PHONY: all

all: bin/hexpatch bin/hexpatch_static

bin/hexpatch: $(HEXPATCH_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\t    LD\t    $@"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) $^ -o $@ $(LDFLAGS)
	@echo -e "\t    STRIP\t    $@"
	@$(STRIP) $(STRIPFLAGS) $@

bin/hexpatch_static: $(HEXPATCH_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\t    LD\t    $@"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) $^ -o $@ $(LDFLAGS)
	@echo -e "\t    STRIP\t    $@"
	@$(STRIP) $(STRIPFLAGS) $@
