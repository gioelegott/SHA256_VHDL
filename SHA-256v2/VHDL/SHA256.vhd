LIBRARY ieee;
USE     ieee.std_logic_1164.ALL;


ENTITY SHA256 IS
--SHA256 reads input characters until '\0' and returnes the digested message

  GENERIC (CONSTANT odim : INTEGER := 256;                --output dimension
           CONSTANT idim : INTEGER := 8);                 --input dimension

  PORT    (clk  : IN  STD_LOGIC;                          --clock
           rst  : IN  STD_LOGIC;                          --reset
           enbl : IN  STD_LOGIC;                          --enable
           inp  : IN  STD_LOGIC_VECTOR (idim-1 DOWNTO 0); --input
           cts  : OUT STD_LOGIC;                          --clear to send
           outd : OUT STD_LOGIC_VECTOR (odim-1 DOWNTO 0); --output data
           outr : OUT STD_LOGIC);                         --output ready
END SHA256;


ARCHITECTURE structural OF SHA256 IS

  COMPONENT paddingSHA256 IS
  PORT    (clk  : IN  STD_LOGIC;
           rst  : IN  STD_LOGIC;
           enbl : IN  STD_LOGIC;                   
           inp  : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
           ack  : IN  STD_LOGIC;
           cts  : OUT STD_LOGIC;   
           outd : OUT STD_LOGIC_VECTOR (511 DOWNTO 0);
           outr : OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT extenderSHA256 IS
  PORT    (clk  : IN  STD_LOGIC;                       
           rst  : IN  STD_LOGIC;    
           enbl : IN  STD_LOGIC;                   
           inpd : IN  STD_LOGIC_VECTOR (511 DOWNTO 0);
           inpr : IN  STD_LOGIC; 
           outd : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
           outr : OUT STD_LOGIC;  
           ack  : OUT STD_LOGIC);                       
  END COMPONENT;

  COMPONENT compressorSHA256 IS
  PORT    (clk  : IN  STD_LOGIC;                       
           rst  : IN  STD_LOGIC;
           enbl : IN  STD_LOGIC;                       
           inpd : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);  
           inpr : IN  STD_LOGIC;
           outd : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
           outr : OUT STD_LOGIC);       
  END COMPONENT;

  SIGNAL pad_to_extD      : STD_LOGIC_VECTOR (511 DOWNTO 0); --data signal from padding to extender
  SIGNAL pad_to_extR      : STD_LOGIC;                       --ready signal from padding to extender
  SIGNAL ack              : STD_LOGIC;                       --acknowldge

  SIGNAL ext_to_compD     : STD_LOGIC_VECTOR (31 DOWNTO 0); --data signal from extender to compressor
  SIGNAL ext_to_compR     : STD_LOGIC;                      --ready signal from extender to compressor

  SIGNAL outr_comp        : STD_LOGIC;                      --compressor's output ready

BEGIN
  pad256 : paddingSHA256
             PORT MAP (clk => clk,
                       rst => rst,
                       enbl => enbl,
                       inp => inp,
                       ack => ack ,
                       cts => cts,
                       outd => pad_to_extD,
                       outr => pad_to_extR);

  ext256 : extenderSHA256
             PORT MAP (clk => clk,
                       rst => rst,
                       enbl => enbl,
                       inpd => pad_to_extD,
                       inpr => pad_to_extR,
                       outd => ext_to_compD,
                       outr => ext_to_compR,
                       ack  => ack );

  comp256 : compressorSHA256
             PORT MAP (clk => clk,
                       rst => rst,
                       enbl => enbl,
                       inpd => ext_to_compD,
                       inpr => ext_to_compR,
                       outd => outd,
                       outr => outr_comp);

  outr <= NOT(pad_to_extR) AND NOT(ext_to_compR) AND outr_comp;

END structural;

