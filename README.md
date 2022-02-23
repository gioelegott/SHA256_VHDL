# SHA256 VHDL

The aim of this project is to design and simulate a hardware that computes in pipeline the SHA256 algorithm of any given string.

The core component that computes the algorithm expects a sequence of characters terminated by ‘\0’ as input and it outputs the digested message after some delay.
The input can be fed only when the “cts” signal (clear to send) is ‘1’ and the output can be read correctly only when the respective control signal (“outr”) is ‘1’.

The core component is made of 3 parts that work in pipeline:
  - Padding: reads the input string and divides it in blocks of 512 bits adding padding when necessary
  - Extender: each block of 512 bits (16 words) is extended into 64 words that are computed sequentially
  - Compressor: each word of the extended block is used to update the internal registers that will be added to the final result

The coordination of the 3 components is managed singularly: each component communicates with the others using control signals.

The advantage of this architecture is that the extender and compressor can work in pipeline as soon as the first 512-bit block is ready.
Once the first word of the extender is calculated, the compressor can start its computation and the total throughput will be 32 bits (1 word) digested per clock cycle.

The code has been already tested using GHDL and gtkwave with the most critical inputs.
Further testing can be done by modifying the “msg” string constant in the vectorGenerator.vhd file.

More information about the SHA256 algorithm together with the pseudocode can be found on https://en.wikipedia.org/wiki/SHA-2.
