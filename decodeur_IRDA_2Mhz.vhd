-- Librairies
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decodeur_IRDA_2Mhz is
    Port (
        
        clk_2Mhz    : in std_logic;
        arazb       : in std_logic;
        new_touch   : in std_logic;
        recept      : in std_logic;
        touche      : in std_logic_vector(7 downto 0);

        up          : out std_logic;
        down        : out std_logic;
        valid       : out std_logic;
        s_load_T    : out std_logic;
        canal_T     : buffer unsigned(7 downto 0)

    );
    
end decodeur_IRDA_2Mhz;

architecture Behavioral of decodeur_IRDA_2Mhz is
    
    signal cpt_temps        : unsigned(31 downto 0) := (others => '0');
    signal information_s    : unsigned(7 downto 0);
    signal result           : unsigned(7 downto 0) := (others => '0');
    signal sraz             : std_logic;
    
begin

    information_s <= unsigned(touche);

    decod: process(clk_2Mhz, arazb)
    begin

        if arazb = '0' then
            up          <= '0';
            down        <= '0';
            valid       <= '0';
            s_load_T    <= '0';
            canal_T     <= (others => '0');
        elsif rising_edge(clk_2Mhz) then

            case information_s is
            
                -- UP
                when x"1A" =>
                    if cpt_temps <= 1000 then
                        up <= '1';
                    else
                        up <= '0';
                    end if;

                -- DOWN
                when x"1E" =>
                    if cpt_temps <= 1000 then
                        down <= '1';
                    else
                        down <= '0';
                    end if;

                -- ENTER
                when x"17" =>                   
                    if cpt_temps <= 1000  then
                        valid <= '1';
                        canal_T <= result;
                    else
                        valid <= '0';
                        canal_T <= (others => '0');
                    end if;

                -- OTHER TOUCHS
                when others =>
                    if recept = '1' then
                        if new_touch = '1' then
                            if cpt_temps <= 600000 then
                                s_load_T <= '1';
                            end if;
                        end if;
                    end if;
            
            end case ;

        end if;
    
    end process;
    
    result <=  (result + 1) when information_s = x"1A" else
               (result - 1) when information_s = x"1E" else
               result + information_s when recept = '1';

    sraz <= '0' when (recept = '1') else
            '1';

    -- Comptage
    count: process(clk_2Mhz, arazb)
    begin

        if arazb = '0' then
            cpt_temps <= (others => '0');
        elsif rising_edge(clk_2Mhz) then
            if sraz = '0' then
                cpt_temps <= (others => '0');
            else
                cpt_temps <= cpt_temps + 1;
            end if;
        end if;
        
    end process;    

end architecture;