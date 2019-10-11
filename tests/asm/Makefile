TARGET_ARCH = mips-softfloat-linux-gnu

AS_TEST_SOURCES = $(wildcard *.s)

C_TEST_SOURCES = $(wildcard *.c)

AS_OUTPUTS = $(patsubst %.s,%,${AS_TEST_SOURCES}) $(patsubst %.c,%.out,${C_TEST_SOURCES})

AS_TEXT_DISAS = $(patsubst %.s,%.txt,${AS_TEST_SOURCES}) $(patsubst %.c,%.outtxt,${C_TEST_SOURCES})

all: ${AS_TEXT_DISAS} ${AS_OUTPUTS}

%.txt: %
	${TARGET_ARCH}-objdump -DS -M reg-names=numeric -j .text $< > $@
	${TARGET_ARCH}-objdump -D -j .data $< |tail -n +3 >> $@ || true

#supscalar: superscalar.s
#	${TARGET_ARCH}-gcc -g -nostdlib -march=mips1 -mtune=mips1 $< -o $@

%: %.s
	${TARGET_ARCH}-gcc -g -Wl,--section-start=.data=0x01000000 -nostdlib -march=mips1 -mtune=mips1 $< -o $@

%.out: %.c
	${TARGET_ARCH}-gcc -g -march=mips1 -mtune=mips1 -static $< -o $@

%.outtxt: %.out
	${TARGET_ARCH}-objdump -dS -M reg-names=numeric $< > $@
	${TARGET_ARCH}-objdump -D -j .data $< | tail -n +3 >> $@ || true

clean:
	rm ${AS_OUTPUTS} ${AS_TEXT_DISAS}