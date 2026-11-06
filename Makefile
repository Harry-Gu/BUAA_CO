.PHONY: all check vvp clean run submit wave

check:
	iverilog -Wall -t null *.v

all: vvp run wave

mips.vvp: *.v
	iverilog -o mips.vvp *.v

vvp: mips.vvp

clean:
	rm mips.vvp
	rm submit.zip

wave.vcd: mips.vvp
	vvp mips.vvp

run: wave.vcd

wave: wave.vcd
	gtkwave wave.vcd

submit.zip: *.v
	zip submit.zip *.v

submit: submit.zip
