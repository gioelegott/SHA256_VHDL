LIBRARY ieee;
USE     ieee.std_logic_1164.ALL;
USE     ieee.numeric_std.ALL;

ENTITY extenderSHA256 IS
--extenderSHA256 reads padded 512-bit chunks and extends them into 64 32-bit words

  GENERIC (CONSTANT odim : INTEGER := 32;                 --output dimension
           CONSTANT idim : INTEGER := 512);               --input dimension

  PORT    (clk  : IN  STD_LOGIC;                          --clock
           rst  : IN  STD_LOGIC;                          --reset
           enbl : IN  STD_LOGIC;                          --enable
           inpd : IN  STD_LOGIC_VECTOR (idim-1 DOWNTO 0); --input data
           inpr : IN  STD_LOGIC;                          --input ready
           outd : OUT STD_LOGIC_VECTOR (odim-1 DOWNTO 0); --output data
           outr : OUT STD_LOGIC := '0';                   --output ready    
           ack  : OUT STD_LOGIC := '0');                  --acknowledge out
END extenderSHA256;

ARCHITECTURE rtl OF extenderSHA256 IS

  CONSTANT chunk_dim  : INTEGER := idim/32;                --chunk dimension (in number of words - 512 bit)
  CONSTANT word_dim   : INTEGER := 32;                     --word dimension (in number of bits)
  CONSTANT ext_number : INTEGER := 64;                     --extender number (number of output word from one chunk)
  CONSTANT ws0        : INTEGER := chunk_dim -15;          --index for the computation of s0
  CONSTANT ws1        : INTEGER := chunk_dim -2;           --index for the computation of s1
  CONSTANT wf1        : INTEGER := chunk_dim -16;          --first index for the computation of nww
  CONSTANT wf2        : INTEGER := chunk_dim -7;           --first index for the computation of nww
  CONSTANT LST        : BIT     := '1';                    --listen mode
  CONSTANT CMP        : BIT     := '0';                    --compute mode

  SUBTYPE WORD  IS UNSIGNED (word_dim-1 DOWNTO 0);
  TYPE    CHUNK IS ARRAY    (chunk_dim-1 DOWNTO 0) OF WORD;

  SIGNAL mode          : BIT     := LST;                   --mode: listen or compute
  SIGNAL cnt           : INTEGER := 0;                     --counter
  SIGNAL w             : CHUNK;                            --chunk of 16 register that contains the current status (w(0) is next output)
  SIGNAL s0, s1        : WORD;                         
  SIGNAL rr07, rr17    : WORD;
  SIGNAL rr18, rr19    : WORD;
  SIGNAL sr03, sr10    : WORD;
  SIGNAL nww           : WORD;                             --buffer that contains the next value of w(15)

BEGIN
  PROCESS (clk, rst)
  BEGIN

    --reset handler
    IF (rst = '1') THEN
      mode <= LST;
      cnt <= 0;
      ack <= '0';
    END IF;


    --listening and computing
    IF (clk'EVENT AND clk = '1' AND enbl = '1') THEN
      
      --listen mode: when input is ready it is copied in w
      IF (mode = LST) THEN
        outr <= '0';
        IF (inpr = '1') THEN
          ack <= '1';
          mode <= CMP;
          FOR i IN 0 TO chunk_dim-1 LOOP
            w(i) <= UNSIGNED(inpd (word_dim * (chunk_dim - i)-1 DOWNTO word_dim * (chunk_dim - (i+1))));
          END LOOP;
        END IF;

      --compute mode: outputs w(0), shifts all registers and computes w(15)
      ELSIF (mode = CMP) THEN
        ack <= '0';
        outr <= '1';
        IF (cnt <= ext_number-1) THEN
          cnt <= cnt +1;
          outd <= STD_LOGIC_VECTOR(w(0));
          FOR i IN 0 TO chunk_dim-2 LOOP
            w(i) <= w(i+1);
          END LOOP;
          w(chunk_dim-1) <= nww;
        ELSE
          --message extension is completed (after 64 cycles)
          mode <= LST;
          cnt <= 0;
        END IF;
      END IF;

    END IF;
  END PROCESS;


  --algorithm to compute the next value of w(15)
  rr07 <= rotate_right(w(ws0), 7);
  rr18 <= rotate_right(w(ws0), 18);
  sr03 <= shift_right (w(ws0), 3);
  s0   <= rr07 XOR rr18 XOR sr03;

  rr17 <= rotate_right(w(ws1), 17);
  rr19 <= rotate_right(w(ws1), 19);
  sr10 <= shift_right (w(ws1), 10);
  s1   <= rr17 XOR rr19 XOR sr10;
  
  nww <= s0 + s1 + w(wf1) + w(wf2);

END rtl;
