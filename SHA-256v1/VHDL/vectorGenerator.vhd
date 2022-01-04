LIBRARY ieee;
USE     ieee.std_logic_1164.ALL;
USE     ieee.numeric_std.ALL;

ENTITY vectorGenerator IS
  PORT (dgst : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
        cts  : IN STD_LOGIC;
        clk  : OUT STD_LOGIC;
        rst  : OUT STD_LOGIC;
        msg  : OUT STD_LOGIC_VECTOR (511 DOWNTO 0));
END vectorGenerator;

ARCHITECTURE behavioral OF vectorGenerator IS

  CONSTANT ckP  : TIME := 10 ns;
  SIGNAL   iClk : STD_LOGIC;
  SIGNAL   iRst : STD_LOGIC := '0';

BEGIN

  feed_msg : PROCESS(cts)
  BEGIN
    IF (cts = '1') THEN --(511 => '1', OTHERS => '0');
      msg <= --x"61626380" &
             x"80000000" &
             x"00000000" &
             x"00000000" &
             x"00000000" &
             x"00000000" &
             x"00000000" &
             x"00000000" &
             x"00000000" &
             x"00000000" &
             x"00000000" &
             x"00000000" &
             x"00000000" &
             x"00000000" &
             x"00000000" &
             x"00000000" &
             x"00000000";
             --x"00000018";
    END IF;
  END PROCESS feed_msg;

  clock   : PROCESS
    VARIABLE clkTmp : STD_LOGIC := '0';
    VARIABLE cnt    : INTEGER   := 0;
  BEGIN
    cnt := cnt +1;
    iClk <= clkTmp;
    clkTmp := NOT clkTmp;

    IF (cnt < 140) THEN
      WAIT FOR ckP * 0.5;
    ELSE
      iRst <= '1';
      WAIT;
    END IF;

  END PROCESS clock;

  clk  <= iClk;
  rst <= iRst;

END behavioral;
