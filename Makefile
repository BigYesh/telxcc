CC = gcc
CCFLAGS = -m64 -march=core2 -Wall -std=gnu99 -O3 -pedantic -fno-stack-protector
LD = ld
LDFLAGS =

OBJS = telxcc.o
EXEC = telxcc

all : $(EXEC)

strip : $(EXEC)
	-strip $<

man : telxcc.1.gz

.PHONY : clean
clean :
	-rm -f $(OBJS) $(EXEC) *.1.gz

$(EXEC) : $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

%.o : %.c
	$(CC) -c $(CCFLAGS) -o $@ $<

%.1.gz : %.1
	gzip -c -9 $< > $@

profiled :
	make CCFLAGS="$(CCFLAGS) -fprofile-generate" LDFLAGS="$(LDFLAGS) -fprofile-generate" $(EXEC)
	find . -type f -iname \*.ts -exec sh -c './telxcc -1 -c -v -p 888 < "{}" > /dev/null 2>> profile.log' \;
	find . -type f -iname \*.ts -exec sh -c './telxcc -s -v -p 888 < "{}" > /dev/null 2>> profile.log' \;
	find . -type f -iname \*.ts -exec sh -c './telxcc -1 -v -t 8192 -p 777 < "{}" > /dev/null 2>> profile.log' \;
	find . -type f -iname \*.ts -exec sh -c './telxcc < "{}" > /dev/null 2>> profile.log' \;
	make clean
	make CCFLAGS="$(CCFLAGS) -fprofile-use" LDFLAGS="$(LDFLAGS) -fprofile-use" $(EXEC)
	-rm -f $(OBJS) *.gcda *.gcno *.dyn pgopti.dpi pgopti.dpi.lock

install : strip man
	sudo cp telxcc /usr/local/bin
	sudo mkdir -p /usr/local/share/man/man1
	sudo cp telxcc.1.gz /usr/local/share/man/man1

uninstall :
	sudo rm /usr/local/bin/telxcc
	sudo rm /usr/local/share/man/man1/telxcc.1.gz
