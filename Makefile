CC=gcc

.PHONY = clean run zip tar

CFLAGS=-I. `net-snmp-config --cflags`
BUILDLIBS=`net-snmp-config --libs`

PROGS=isaProj.so
ARCHIVE=xkocal00.tar

# shared library flags (assumes gcc)
DLFLAGS=-fPIC -shared

all: build install

build: $(PROGS)

isaProj.so: isaProj.c
	$(CC) $(CFLAGS) $(DLFLAGS) -c -o isaProj.o isaProj.c
	$(CC) $(CFLAGS) $(DLFLAGS) -o isaProj.so isaProj.o

install:
	module=isaProj
	pathToModule=/home/user/isa/isaProj.so

	#If snmpd is running, stop it
	systemctl is-active --quiet snmpd
	if [ $? == 0 ] ; then
		service snmpd stop
	fi
	#start snmpd
	service snmpd start

	#register the module
	snmpset localhost UCD-DLMOD-MIB::dlmodStatus.1 i create
	snmpset localhost UCD-DLMOD-MIB::dlmodName.1 s "$module" UCD-DLMOD-MIB::dlmodPath.1 s "$pathToModule"
	snmpset localhost UCD-DLMOD-MIB::dlmodStatus.1 i load
	snmptable localhost UCD-DLMOD-MIB::dlmodTable

clean:
	rm -f isaProj.so isaProj.o

tar:
	tar -c -f $(ARCHIVE) *.c *.h Makefile ISA-PROJ-MIB.txt README