-- Librairies
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Recept_trame_IRDA_2Mhz is
    Port (
        
        clk_2Mhz    : in std_logic;
        arazb       : in std_logic;
        IRDA        : in std_logic;

        Mot_32bits  : buffer std_logic_vector(31 downto 0);
        Recept      : out std_logic;
        new_touche  : out std_logic     

    );
    
end Recept_trame_IRDA_2Mhz;

architecture Behavioral of Recept_trame_IRDA_2Mhz is
    
    type etat_mae_t 	is (et0, et1, et2, et3, et4, et5);
    
    signal etat_present : etat_mae_t;
    signal cpt_temps    : unsigned(16 downto 0) := (others => '0');
    signal cpt_bits     : natural range 0 to 32 := 0;
    signal IRDA_s	: std_logic;
    signal sraz		: std_logic;
    signal I_IRDA	: std_logic;
    
    signal tr0_1, tr1_0, tr1_2, tr2_5, tr2_3, tr3_4, tr4_3_0, tr4_3_1, tr5_0, tr4_5	: boolean;

begin

    -- Inversion according to IR specifications
    IRDA_s <= not(I_IRDA);
	
    -- Transitions
    tr0_1 <= (IRDA_s = '1');
    tr1_0 <= (cpt_temps > 20000 and IRDA_s = '0') or (IRDA_s = '0' and cpt_temps < 16000);
    tr1_2 <= (IRDA_s = '0' and cpt_temps <= 20000 and cpt_temps >= 16000);
    tr2_5 <= (IRDA_s = '1' and cpt_temps <= 5000 and cpt_temps >= 4000);
    tr2_3 <= (IRDA_s = '1' and cpt_temps > 5000);
    tr3_4 <= (IRDA_s = '0');
    tr4_3_0 <= (IRDA_s = '1' and cpt_temps <= 1300 and cpt_temps >= 1000 and cpt_bits /= 32);
    tr4_3_1 <= (IRDA_s = '1' and cpt_temps > 1300 and cpt_bits /= 32);
    tr5_0 <= (IRDA_s = '0');
    tr4_5 <= (IRDA_s = '1' and cpt_bits = 32);

    -- State Machine
    mae: process(clk_2Mhz, arazb, IRDA_s, cpt_temps, cpt_bits)
       
    begin

        if arazb = '0' then
            Mot_32bits <= (others => '0');
            etat_present <= et0;
            cpt_bits <= 0;
        elsif rising_edge(clk_2Mhz) then
            case etat_present is

                when et0 =>
                    if tr0_1 then
                        etat_present <= et1;
                        cpt_bits <= 0;
                    end if;
                
                when et1 => 
                    if tr1_0 then
                        etat_present <= et0;
                    elsif tr1_2 then
                        etat_present <= et2;
                    end if;

                when et2 =>
                    if tr2_5 then
                        etat_present <= et5;
                    elsif tr2_3 then
                        etat_present <= et3;
                    end if;	

                when et3 =>
                    if tr3_4 then
                        etat_present <= et4;
                    end if;
                
                when et4 => 
                    if tr4_3_0 then
                        Mot_32bits <= '0'&Mot_32bits(31 downto 1);
                        cpt_bits <= cpt_bits + 1;
                        etat_present <= et3;
                    elsif tr4_3_1 then
                        Mot_32bits <= '1'&Mot_32bits(31 downto 1);
                        cpt_bits <= cpt_bits + 1; 
                        etat_present <= et3;
                    elsif tr4_5 then
                        etat_present <= et5;
                    end if;

                when et5 =>
                    if tr5_0 then
                        etat_present <= et0;
                    end if;

            end case;
        end if;

    end process;
    
    Recept 	<= 1' when (etat_present = et4 and tr4_5)
		      or (etat_present = et2 and tr2_5)
		      else '0';
		   
    new_touche 	<= '1' when (etat_present = et4 and tr4_5)
		       else '0';
							
    sraz 	<= '1' when (etat_present = et1 or etat_present = et2 or etat_present = et4)
		       else '0';

   -- Counting
   count: process(clk_2Mhz, arazb)
    begin

        if arazb = '0' then
            cpt_temps <= (others => '0');
        elsif rising_edge(clk_2Mhz) then
            if sraz = '0' or (etat_present = et1 and tr1_2) then
				cpt_temps <= (others => '0');
            else
                cpt_temps <= cpt_temps + 1;
            end if;
        end if;
       
    end process;
	 
   -- Avoid Metastability
   n_metastability: process(clk_2Mhz)
    begin
	if rising_edge(clk_2Mhz) then
		I_IRDA <= IRDA;
	end if;
    end process;

end Behavioral;
