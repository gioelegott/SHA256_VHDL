LIBRARY ieee;
USE     ieee.std_logic_1164.ALL;
USE     ieee.numeric_std.ALL;

ENTITY extenderSHA256 IS
  PORT    (clk  : IN  STD_LOGIC;                       --clock
           rst  : IN  STD_LOGIC;                       --reset
           inp  : IN  STD_LOGIC_VECTOR (511 DOWNTO 0); --input
           outp : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);  --output
           cts  : OUT STD_LOGIC);                      --clear to send
END extenderSHA256;

ARCHITECTURE behavioral OF extenderSHA256 IS

  CONSTANT chunk_dim  : INTEGER := 16;                  --chunk dimension (in numero di word - 512 bit)
  CONSTANT word_dim   : INTEGER := 32;                  --word dimension (in numero di bit)
  CONSTANT ext_number : INTEGER := 64;                  --extender number: numero finale di parole in uscita
  CONSTANT ws0        : INTEGER := chunk_dim -15;       --indice di w per il calcolo di s0
  CONSTANT ws1        : INTEGER := chunk_dim -2;        --indice di w per il calcolo di s1
  CONSTANT wf1        : INTEGER := chunk_dim -16;       --indice1 di w per il calcolo di nww
  CONSTANT wf2        : INTEGER := chunk_dim -7;        --indice2 di w per il calcolo di nww
  CONSTANT LST        : BIT     := '1';                 --listen mode
  CONSTANT CMP        : BIT     := '0';                 --compute mode

  SUBTYPE WORD  IS UNSIGNED (word_dim-1 DOWNTO 0);
  TYPE    CHUNK IS ARRAY    (chunk_dim-1 DOWNTO 0) OF WORD;

  SIGNAL mode                   : BIT     := LST;      --modalita': listen o compute
  SIGNAL cnt                    : INTEGER := 0;        --contatore
  SIGNAL w                      : CHUNK;               --16 registri che contengono lo stato corrente. w(0) e' l'output
  SIGNAL s0, s1                 : WORD;                
  SIGNAL rr07, rr17, rr18, rr19 : WORD;
  SIGNAL sr03, sr10             : WORD;
  SIGNAL nww                    : WORD;                --segnale che indica ad ogni ciclo il prossimo w(15)
  
BEGIN

  cts <= '1' WHEN (mode = LST) ELSE 
         '0' WHEN (mode = CMP) ELSE
         'X';

  PROCESS (clk, rst)
  BEGIN
    IF (rst = '1') THEN
      mode <= LST;
      cnt <= 0;
    END IF;

    IF (clk'EVENT AND clk = '1') THEN

      IF (mode = LST) THEN
        mode <= CMP;
        FOR i IN 0 TO chunk_dim-1 LOOP
          w(i) <= UNSIGNED(inp (word_dim * (chunk_dim - i)-1 DOWNTO word_dim * (chunk_dim - (i+1))));
        END LOOP;

      ELSIF (mode = CMP) THEN
        IF (cnt <= ext_number-1) THEN
          cnt <= cnt +1;
          outp <= STD_LOGIC_VECTOR(w(0));
          FOR i IN 0 TO chunk_dim-2 LOOP
            w(i) <= w(i+1);
          END LOOP;
          w(chunk_dim-1) <= nww;
        ELSE                            --se ha fatto 64 output azzera il contatore e si mette in modalita' listen
          mode <= LST;
          cnt <= 0;
        END IF;
      END IF;

    END IF;

  END PROCESS;

  --algoritmo per il calcolo del prossimo valore di w(15)
  rr07 <= rotate_right(w(ws0), 7);
  rr18 <= rotate_right(w(ws0), 18);
  sr03 <= shift_right (w(ws0), 3);
  s0   <= rr07 XOR rr18 XOR sr03;

  rr17 <= rotate_right(w(ws1), 17);
  rr19 <= rotate_right(w(ws1), 19);
  sr10 <= shift_right (w(ws1), 10);
  s1   <= rr17 XOR rr19 XOR sr10;
  
  nww <= s0 + s1 + w(wf1) + w(wf2);

END behavioral;