APP = RTX
CC = clang++
FLAGS =	-W -Wall -ansi -pedantic -I./source/Utilities/
LINKS = -lSDL2
RM = rm -rf

SOURCE = $(wildcard ./source/*/*.cpp)
INCLUDE = $(wildcard ./source/*/*.h)
OBJECTS = $(subst .cpp,.o,$(subst source/*,build/objects,$(SOURCE)))

all: build/$(APP)

./build/$(APP): $(OBJECTS)
	@ echo 'Building binary $@'
	$(CC) $^ $(FLAGS) $(LINKS) -o $@

./build/objects/%.o: ./source/%.cpp ./include/%.h
	@ echo 'Building target $<'
	$(CC) $< $(FLAGS) $(LINKS) -o $@

./build/objects/main.o: ./source/main.cpp
	@ echo 'Building target $<'
	$(CC) $< $(FLAGS) $(LINKS) -o $@

clean:
	@ $(RM) ./source/*/*.o ./build/$(APP) *~

run:
	./build/$(APP)

it:
	make all run clean
