
--https://gist.github.com/hak8or/8794351
--https://calc.penjee.com/
--GAISLER STANDARD https://www.gaisler.com/doc/vhdl2proc.pdf 
--https://gist.github.com/hak8or/8794351
--https://calc.penjee.com/
LIBRARY ieee;
USE     ieee.std_logic_1164.ALL;

--FIND_LEFTMOST

ENTITY SHA256 IS
  PORT    (clk  : IN  STD_LOGIC;
           rst  : IN  STD_LOGIC;
           msgi : IN  STD_LOGIC_VECTOR (511 DOWNTO 0);
           cts  : OUT STD_LOGIC;
           msgo : OUT STD_LOGIC_VECTOR (255 DOWNTO 0));
END SHA256;


ARCHITECTURE structural OF SHA256 IS
  
  COMPONENT extenderSHA256 IS
  PORT    (clk  : IN  STD_LOGIC;                       
           rst  : IN  STD_LOGIC;                       
           inp  : IN  STD_LOGIC_VECTOR (511 DOWNTO 0); 
           outp : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);        
           cts  : OUT STD_LOGIC);                       
  END COMPONENT;

  COMPONENT compressorSHA256 IS
  PORT    (clk  : IN  STD_LOGIC;                       
           rst  : IN  STD_LOGIC;
           enbl : IN  STD_LOGIC;                       
           inp  : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);  
           outp : OUT STD_LOGIC_VECTOR (255 DOWNTO 0));       
  END COMPONENT;

  SIGNAL ext_to_comp : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL ctsi, enbli : STD_LOGIC;

BEGIN
  ext256 : extenderSHA256
             PORT MAP (clk => clk,
                       rst => rst,
                       inp => msgi,
                       outp => ext_to_comp,
                       cts  => ctsi);

  comp256 : compressorSHA256
             PORT MAP (clk => clk,
                       rst => rst,
                       enbl => enbli,
                       inp => ext_to_comp,
                       outp => msgo);
  
  cts <= ctsi;  

  PROCESS (clk)
  BEGIN
    IF (clk = '1') THEN
      enbli <= NOT ctsi;
    END IF;
  END PROCESS;

END structural;

