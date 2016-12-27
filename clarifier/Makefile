CC=g++
# use the wildcard function just like wildcard
# SRC = $(wildcard ../src/*.cpp)
SRC = clarifier.cpp
# use the notdir function to strip directory from name
# then use the other part to substiture .cpp with .o
OBJ = $(notdir $(SRC:.cpp=.o))
CFLAGS=-g -std=c++14 -c -Wall
EXECUTABLE = clarifier
LDFLAGS=-lconfig++
# first you the all target
all: $(EXECUTABLE)

# the all target calls to build the .o files
# the including of the flags is on the objects
$(EXECUTABLE): $(OBJ)
	$(CC) $^ -o $(EXECUTABLE) $(LDFLAGS)

# the .o calls to build the SRC files
$(OBJ): $(SRC)
	$(CC) $(CFLAGS) $^ 

clean:
	rm -f $(OBJ) $(EXECUTABLE)
