LIBRARY ieee;
USE     ieee.std_logic_1164.ALL;
USE     ieee.numeric_std.ALL;

ENTITY compressorSHA256 IS
--compressorSHA256 reads 64 32-bit words and compresses them into a 256-bit digested message

  GENERIC (CONSTANT odim : INTEGER := 256;                 --output dimension
           CONSTANT idim : INTEGER := 32);                 --input dimension

  PORT    (clk  : IN  STD_LOGIC;                           --clock
           rst  : IN  STD_LOGIC;                           --reset
           enbl : IN  STD_LOGIC;                           --enable
           inpd : IN  STD_LOGIC_VECTOR (idim-1 DOWNTO 0);  --input data
           inpr : IN  STD_LOGIC;                           --input ready
           outd : OUT STD_LOGIC_VECTOR (odim-1 DOWNTO 0);  --output data
           outr : OUT STD_LOGIC := '0');                   --output ready
END compressorSHA256;

ARCHITECTURE behavioral OF compressorSHA256 IS

  CONSTANT k_dim    : INTEGER     := 64;                   --dimension of k (2048 bit)
  CONSTANT word_dim : INTEGER     := 32;                   --word dimension
  CONSTANT cycles   : INTEGER     := 64;                   --number of cycles

  SUBTYPE WORD        IS UNSIGNED (word_dim-1 DOWNTO 0);
  TYPE    CONST_ARRAY IS ARRAY    (0 TO k_dim-1) OF WORD;

  CONSTANT k        : CONST_ARRAY := (x"428a2f98", x"71374491", x"b5c0fbcf", x"e9b5dba5", x"3956c25b", x"59f111f1", x"923f82a4", x"ab1c5ed5",
                                      x"d807aa98", x"12835b01", x"243185be", x"550c7dc3", x"72be5d74", x"80deb1fe", x"9bdc06a7", x"c19bf174",
                                      x"e49b69c1", x"efbe4786", x"0fc19dc6", x"240ca1cc", x"2de92c6f", x"4a7484aa", x"5cb0a9dc", x"76f988da",
                                      x"983e5152", x"a831c66d", x"b00327c8", x"bf597fc7", x"c6e00bf3", x"d5a79147", x"06ca6351", x"14292967",
                                      x"27b70a85", x"2e1b2138", x"4d2c6dfc", x"53380d13", x"650a7354", x"766a0abb", x"81c2c92e", x"92722c85",
                                      x"a2bfe8a1", x"a81a664b", x"c24b8b70", x"c76c51a3", x"d192e819", x"d6990624", x"f40e3585", x"106aa070",
                                      x"19a4c116", x"1e376c08", x"2748774c", x"34b0bcb5", x"391c0cb3", x"4ed8aa4a", x"5b9cca4f", x"682e6ff3",
                                      x"748f82ee", x"78a5636f", x"84c87814", x"8cc70208", x"90befffa", x"a4506ceb", x"bef9a3f7", x"c67178f2");

  SIGNAL cnt        : INTEGER     := 0;                 --counter

  SIGNAL h0, a      : WORD        :=  x"6a09e667";
  SIGNAL h1, b      : WORD        :=  x"bb67ae85";
  SIGNAL h2, c      : WORD        :=  x"3c6ef372";
  SIGNAL h3, d      : WORD        :=  x"a54ff53a";
  SIGNAL h4, e      : WORD        :=  x"510e527f";
  SIGNAL h5, f      : WORD        :=  x"9b05688c";
  SIGNAL h6, g      : WORD        :=  x"1f83d9ab";
  SIGNAL h7, h      : WORD        :=  x"5be0cd19";

  SIGNAL s0, s1     : WORD;
  SIGNAL maj        : WORD;
  SIGNAL t1n, t2    : WORD;
  SIGNAL ch         : WORD;

  SIGNAL rr02, rr06 : WORD;
  SIGNAL rr11, rr13 : WORD;
  SIGNAL rr22, rr25 : WORD;

BEGIN

  PROCESS (rst, clk)
  BEGIN

    --reset handler
    IF (rst = '1') THEN
      cnt  <= 0;
      outr <= '0';
      h0   <= x"6a09e667";  a <= x"6a09e667";
      h1   <= x"bb67ae85";  b <= x"bb67ae85";
      h2   <= x"3c6ef372";  c <= x"3c6ef372";
      h3   <= x"a54ff53a";  d <= x"a54ff53a";
      h4   <= x"510e527f";  e <= x"510e527f";
      h5   <= x"9b05688c";  f <= x"9b05688c";
      h6   <= x"1f83d9ab";  g <= x"1f83d9ab";
      h7   <= x"5be0cd19";  h <= x"5be0cd19";
    END IF;
    
    --compressing
    IF (clk'EVENT AND clk = '1' AND enbl = '1' AND inpr = '1') THEN

      --shuffling registers and adding input and k
      IF (cnt < cycles) THEN
        cnt  <= cnt + 1;
        outr <= '0';
        h    <= g;
        g    <= f;
        f    <= e;
        e    <= d + t1n + UNSIGNED(inpd) + k(cnt);
        d    <= c;
        c    <= b;
        b    <= a;
        a    <= t1n + t2 + UNSIGNED(inpd) + k(cnt);
      
      --updating accumulation registers and resetting algorithm
      ELSE
        cnt  <= 0;
        outr <= '1';
        h0   <= h0 + a;  a  <= h0 + a;
        h1   <= h1 + b;  b  <= h1 + b;
        h2   <= h2 + c;  c  <= h2 + c;
        h3   <= h3 + d;  d  <= h3 + d;
        h4   <= h4 + e;  e  <= h4 + e;
        h5   <= h5 + f;  f  <= h5 + f;
        h6   <= h6 + g;  g  <= h6 + g;
        h7   <= h7 + h;  h  <= h7 + h;
      END IF;
    END IF;

  END PROCESS;

  --algorithm to compute t1n and t2
  rr02 <= rotate_right(a, 2);
  rr13 <= rotate_right(a, 13);
  rr22 <= rotate_right(a, 22);
  s0   <= rr02 XOR rr13 XOR rr22;

  rr06 <= rotate_right(e, 6);
  rr11 <= rotate_right(e, 11);
  rr25 <= rotate_right (e, 25);
  s1   <= rr06 XOR rr11 XOR rr25;

  maj  <= (a AND b) XOR (a AND c) XOR (b AND c);
  ch   <= (e AND f) XOR ((NOT e) AND g);

  t1n  <= h + s1 + ch;
  t2   <= s0 + maj;

  --output updating
  outd <= STD_LOGIC_VECTOR(h0) &
          STD_LOGIC_VECTOR(h1) &
          STD_LOGIC_VECTOR(h2) &
          STD_LOGIC_VECTOR(h3) &
          STD_LOGIC_VECTOR(h4) &
          STD_LOGIC_VECTOR(h5) &
          STD_LOGIC_VECTOR(h6) &
          STD_LOGIC_VECTOR(h7);

END behavioral;