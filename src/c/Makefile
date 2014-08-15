CC=gcc
SOURCES=curlkdb.c
OBJECTS=$(SOURCES:.c=.o)
SHAREDLIB=curlkdb.so
KDB_CFLAGS = -DKXVER=3
ARCH = -m32
#KDB_CFLAGS = 
#-lxml2 -lz -lm
CFLAGS= $(ARCH) -c -ggdb  -I/usr/local/i386/include -fPIC $(KDB_CFLAGS) -Wno-format
LDFLAGS= $(ARCH) -L/usr/local/lib/ -lcurl -lpthread -shared 

all: $(SOURCES) $(SHAREDLIB)
	
$(SHAREDLIB): $(OBJECTS) 
	$(CC) $(OBJECTS) $(LDFLAGS) -fPIC -o lib$@

.c.o:
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -rf *o *.so
