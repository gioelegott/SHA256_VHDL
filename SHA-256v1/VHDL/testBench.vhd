LIBRARY ieee;
USE     ieee.std_logic_1164.ALL;
USE     ieee.numeric_std.ALL;

ENTITY testBench IS
END testBench;

ARCHITECTURE structural OF testBench IS

  COMPONENT SHA256
  PORT    (clk  : IN  STD_LOGIC;
           rst  : IN  STD_LOGIC;
           msgi : IN  STD_LOGIC_VECTOR (511 DOWNTO 0);
           cts  : OUT STD_LOGIC;
           msgo : OUT STD_LOGIC_VECTOR (255 DOWNTO 0));
  END COMPONENT;


  COMPONENT vectorGenerator
  PORT (dgst : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
        cts  : IN STD_LOGIC;
        clk  : OUT STD_LOGIC;
        rst  : OUT STD_LOGIC;
        msg  : OUT STD_LOGIC_VECTOR (511 DOWNTO 0));
  END COMPONENT;

  SIGNAL clkTB, rstTB : STD_LOGIC;
  SIGNAL ctsTB        : STD_LOGIC;
  SIGNAL msgTB        : STD_LOGIC_VECTOR (511 DOWNTO 0);
  SIGNAL dgstTB       : STD_LOGIC_VECTOR (255 DOWNTO 0);

BEGIN
  hash : SHA256
           PORT MAP (clk  => clkTB,
                     rst  => rstTB,
                     msgi => msgTB,
                     cts  => ctsTB,
                     msgo => dgstTB);

  vect : vectorGenerator
           PORT MAP (dgst => dgstTB,
                     cts  => ctsTB,
                     clk  => clkTB,
                     rst  => rstTB,
                     msg  => msgTB);
END structural;
