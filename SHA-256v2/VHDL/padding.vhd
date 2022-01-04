LIBRARY ieee;
USE     ieee.std_logic_1164.ALL;
USE     ieee.numeric_std.ALL;

ENTITY paddingSHA256 IS
--paddingSHA256 reads input characters until '\0' and packs them in 512-bit words with padding ('\0' is ignored)

  GENERIC (CONSTANT odim : INTEGER := 512;                 --output dimension
           CONSTANT idim : INTEGER := 8);                  --input dimension

  PORT    (clk  : IN  STD_LOGIC;                           --clock
           rst  : IN  STD_LOGIC;                           --reset
           enbl : IN  STD_LOGIC;                           --enable
           inp  : IN  STD_LOGIC_VECTOR (idim-1 DOWNTO 0);  --input (char)
           ack  : IN  STD_LOGIC;                           --acknowledge in
           cts  : OUT STD_LOGIC := '1';                    --clear to sent out
           outd : OUT STD_LOGIC_VECTOR (odim -1 DOWNTO 0); --output data
           outr : OUT STD_LOGIC);                          --output ready
END paddingSHA256;

ARCHITECTURE rtl OF paddingSHA256 IS

  CONSTANT ldim : INTEGER   := 64;                               --dimension of message length
  
  SIGNAL cnt    : INTEGER   := 0;                                --counter
  SIGNAL ifin   : STD_LOGIC := '0';                              --input finished
  SIGNAL ovf    : STD_LOGIC := '0';                              --overflow
  SIGNAL padr   : STD_LOGIC := '0';                              --padding ready
  SIGNAL outri  : STD_LOGIC := '0';                              --output ready internal
  SIGNAL o_end  : STD_LOGIC := '0';                              --output ended
  SIGNAL len    : UNSIGNED (ldim-1 DOWNTO 0) := (OTHERS => '0'); --total input length

BEGIN

  PROCESS (clk, rst)
    VARIABLE ackr         : STD_LOGIC := '1';                    --acknowledge ready (acknowledge has arrived)
  BEGIN

    --reset handler
    IF (rst = '1') THEN
      cts   <= '1';
      outri <= '0';

      cnt   <= 0;
      ackr  := '1';
      ifin  <= '0';
      ovf   <= '0';
      padr  <= '0';
      len   <= (OTHERS => '0');
    END IF;


    IF (clk'EVENT AND clk = '1' AND enbl ='1') THEN

      --ackowledge handler
      IF (ack = '1') THEN
        ackr := '1';
      ELSIF (outri = '1') THEN
        ackr := '0';
      END IF;

      --input handler
      IF (inp = "00000000") THEN --input ended
        ifin <= '1'; --go to padding
        cts <= '0';
      ELSE
        IF (ackr = '1' AND cnt*8 < odim) THEN
          outri <= '0';
          cts <= '1';
          cnt <= cnt +1;
          len <= len +8;
          outd (odim - cnt*8 -1 DOWNTO odim - (cnt+1)*8) <= inp; --filling outd
        ELSE --outd is full
          cts <= '0';
          outri <= '1';
          cnt <= 0;
        END IF;
      END IF;
      
      --padding handler
      IF (ifin = '1' AND ackr = '1' AND padr = '0') THEN
        outri <= '1';
        padr  <= '1';
        IF (cnt*8 < odim - ldim) THEN --adding padding
          o_end <= '1';
          outd (odim - 1 - cnt*8) <= '1';
          outd (odim - 2 - cnt*8 DOWNTO ldim) <= (OTHERS => '0');
          outd (ldim -1 DOWNTO 0) <= STD_LOGIC_VECTOR(len);
        ELSE
          ovf <= '1'; --go to overflow
          IF (cnt*8 /= odim) THEN --outd is NOT completely full
            outd (odim - 1 - cnt*8) <= '1';
            outd (odim - 2 - cnt*8 DOWNTO 0) <= (OTHERS => '0');
          END IF;
        END IF;
      END IF;

      --overflow handler
      IF (ovf = '1' AND ackr = '1') THEN
        o_end <= '1';
        ovf <= '0';

        IF (cnt*8 /= odim) THEN --outd was NOT completely full
          outd (odim - 1 DOWNTO ldim) <= (OTHERS => '0');
        ELSE                    --outd was completely full
          outd (odim - 1) <= '1';
          outd (odim - 2  DOWNTO ldim) <= (OTHERS => '0');
        END IF; 
        
        outd (ldim -1 DOWNTO 0) <= STD_LOGIC_VECTOR(len);
      END IF;
      
      --output is not ready if elaboration is completed
      IF (o_end = '1' AND ackr = '1') THEN
        outri <= '0';
      END IF;

    END IF;     

  END PROCESS; 

  outr <= outri;

END rtl;