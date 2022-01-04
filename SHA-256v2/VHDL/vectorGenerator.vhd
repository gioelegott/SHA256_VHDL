LIBRARY ieee;
USE     ieee.std_logic_1164.ALL;
USE     ieee.numeric_std.ALL;

--Online SHA256 calculator for testing and debugging
--https://emn178.github.io/online-tools/sha256.html

ENTITY vectorGenerator IS
  PORT (inpd : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
        inpr : IN STD_LOGIC;
        cts  : IN STD_LOGIC;
        clk  : OUT STD_LOGIC;
        rst  : OUT STD_LOGIC;
        enbl : OUT STD_LOGIC;
        outd : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
END vectorGenerator;

ARCHITECTURE behavioral OF vectorGenerator IS

  CONSTANT msg   : STRING  := ""; --message to be digested

  --TESTS DONE: length 0  : ""    
  --                      -> e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
  --            length 3  : "abc"
  --                      -> ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
  --            length 57 : "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234" 
  --                      -> f657700bee98bf60880401a6ea1e6e32fecc61cf4e22dab560f58ad30e001482
  --            lenght 63 : "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
  --                      -> 7433ede2565cd53506358f2795c3237c714785dacdca6e8f4fb7b16fe78ee1ec
  --            lenght 64 : "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789__"
  --                      -> 4d666fe11523782a619ab67dba6573ad55fb4e569dbf9973be7ec92c07a8c7e5
  --            lenght 65 : "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789__0"
  --                      -> 287d2494748f5e5e3324c0557bd97f19148ee6ddebb9466dfdcf634a4da7c665
  --            lenght 127: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789__"
  --                      -> d920b34bc7036b6097ca6931c0a69b1b1affe9a4e4943b3f526c0667e19a1d0f
  --            lenght 128: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789___"
  --                      -> 3e707b2adc747f8ddfbf6556f6a280eedb34851f81f0a710a3bd352d4e122060

  SIGNAL   cnt   : INTEGER := 0;

  CONSTANT ckP  : TIME := 10 ns;
  SIGNAL   iClk : STD_LOGIC;
  SIGNAL   iRst : STD_LOGIC := '0';

BEGIN

  feed_msg : PROCESS(iClk)
  BEGIN
    IF (iClk = '1') THEN
      IF (cts = '1') THEN
        IF (cnt < msg'LENGTH) THEN
          outd <= STD_LOGIC_VECTOR(TO_UNSIGNED(NATURAL(CHARACTER'POS(msg(cnt+1))), 8));
          cnt <= cnt +1;
        ELSE
          outd <= (OTHERS => '0');
        END IF;
      END IF;
    END IF;

  END PROCESS feed_msg;

  clock   : PROCESS
    VARIABLE clkTmp : STD_LOGIC := '0';
    VARIABLE   icnt   : INTEGER := 0;

  BEGIN
    icnt := icnt +1;
    iClk <= clkTmp;
    clkTmp := NOT clkTmp;

    IF (icnt < (msg'LENGTH/32 +2)*2*64 + 32) THEN
      WAIT FOR ckP * 0.5;
    ELSE
      iRst <= '1';
      WAIT;
    END IF;

  END PROCESS clock;

  clk  <= iClk;
  rst <= iRst;
  enbl <= NOT(inpr);

END behavioral;
