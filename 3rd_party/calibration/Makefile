MAIN=calibrate
LINK.o = $(LINK.cpp)
LDFLAGS=`pkg-config opencv --libs`
INCLUDES=
CXXFLAGS=`pkg-config opencv --cflags` $(INCLUDES) -Wall -O2
OBJ=$(MAIN).o

all: $(MAIN)

$(MAIN): $(OBJ)

%.d: %.C
	$(CXX) -M $(CXXFLAGS) $< >$@

clean:
	rm -f $(MAIN) $(OBJ) $(OBJ:.o=.d)

-include $(OBJ:.o=.d)
