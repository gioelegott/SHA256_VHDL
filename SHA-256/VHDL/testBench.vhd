LIBRARY ieee;
USE     ieee.std_logic_1164.ALL;
USE     ieee.numeric_std.ALL;

ENTITY testBench IS
END testBench;

ARCHITECTURE structural OF testBench IS

  COMPONENT SHA256
  PORT    (clk  : IN  STD_LOGIC;
           rst  : IN  STD_LOGIC;
           enbl : IN  STD_LOGIC;
           inp  : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
           cts  : OUT STD_LOGIC;
           outd : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
           outr : OUT STD_LOGIC);
  END COMPONENT;


  COMPONENT vectorGenerator
  PORT (inpd : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
        inpr : IN STD_LOGIC;
        cts  : IN STD_LOGIC;
        clk  : OUT STD_LOGIC;
        rst  : OUT STD_LOGIC;
        enbl : OUT STD_LOGIC;
        outd : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
  END COMPONENT;

  SIGNAL clkTB, rstTB, enblTB : STD_LOGIC;
  SIGNAL ctsTB                : STD_LOGIC;
  SIGNAL msgTB                : STD_LOGIC_VECTOR (7 DOWNTO 0);
  SIGNAL dgstTB               : STD_LOGIC_VECTOR (255 DOWNTO 0);
  SIGNAL outrTB               : STD_LOGIC;

BEGIN
  hash : SHA256
           PORT MAP (clk  => clkTB,
                     rst  => rstTB,
                     enbl => enblTB,
                     inp  => msgTB,
                     cts  => ctsTB,
                     outd => dgstTB,
                     outr => outrTB);

  vect : vectorGenerator
           PORT MAP (inpd => dgstTB,
                     inpr => outrTB,
                     cts  => ctsTB,
                     clk  => clkTB,
                     rst  => rstTB,
                     enbl => enblTB,
                     outd  => msgTB);
END structural;
