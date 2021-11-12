-- Librairies
library ieee;
use     ieee.std_logic_1164.all;

-- Déclaration des composants dans le package
package vhdl_pack is

    component Acq_TELECO is
        Port (
            
            Recept      : in std_logic;
    
            UP          : out std_logic;
            DOWN        : out std_logic;
            Valid       : out std_logic;
            CANAL       : out std_logic;
            S_load_t    : out std_logic     
    
        );
        
    end component;

    component Acq_CANAL is
        Port (
            
            UP          : in std_logic;
            DOWN        : in std_logic;
            INIT        : in std_logic;
            Valid       : in std_logic;
    
            UP_T        : in std_logic;
            DOWN_T      : in std_logic;
            Valid_T     : in std_logic;
            CANAL_T     : in std_logic;
            S_load_t    : in std_logic;
    
            CANAL               : out std_logic_vector(9 downto 0);
            Validation_CANAL    : out std_logic
    
        );
        
    end component;

    component Memorisation_CANAL is
        Port (
            
            CANAL               : in std_logic_vector(9 downto 0);
            Validation_CANAL    : in std_logic_vector(6 downto 0);
    
            CANAL_memorise      : out std_logic_vector(8 downto 0)
    
        );
        
    end component;

    component Aff_CANAL is
        Port (
            
            CANAL       : in std_logic_vector(9 downto 0);
    
            UNI         : out std_logic_vector(6 downto 0);
            DIZ         : out std_logic_vector(6 downto 0);
            CEN         : out std_logic_vector(6 downto 0) 
    
        );

    end component;
        
    component Recept_trame_IRDA_2Mhz is
        Port (
            
            clk_2Mhz    : in std_logic;
            arazb       : in std_logic;
            IRDA        : inout std_logic;

            Mot_32bits  : inout std_logic_vector(31 downto 0);
            Recept      : out std_logic;
            new_touche  : out std_logic     

        );
    
    end component;

end package;
