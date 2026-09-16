library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity programmable_counter is
    generic (
        N : integer := 8  -- Width of the counter
    );
    port (
        clk     : in  std_logic;          -- Clock input
        rst_n   : in  std_logic;          -- Asynchronous reset input
        enable  : in  std_logic;          -- Enable input
        load    : in  std_logic;          -- Load input
        load_value : in  std_logic_vector(N-1 downto 0); -- Value to load into the counter
        limit_value : in  std_logic_vector(N-1 downto 0); -- Limit value for the counter
        count   : out std_logic_vector(N-1 downto 0);  -- Counter output
        limit_pulse : out std_logic          -- Limit pulse output
    );
end entity programmable_counter;

architecture rtl of programmable_counter is
    signal counter_reg : std_logic_vector(N-1 downto 0) := (others => '0');
    signal limit_reached : std_logic := '0';
    begin
        count <= counter_reg;
        limit_pulse <= limit_reached;
        process(clk, rst_n)
        begin
            if rst_n = '0' then
                counter_reg <= (others => '0');
                limit_reached <= '0';
            elsif rising_edge(clk) then 
                limit_reached <= '0';

                if load = '1' then
                    counter_reg <= load_value;

                elsif enable ='1' then
                    if (counter_reg = limit_value) then
                        counter_reg <= (others => '0');
                        limit_reached <='1';
                    else
                        counter_reg <= std_logic_vector(unsigned (counter_reg)+1);
                        limit_reached <= '0';

    end if;
    end if;
    end if;
    end process;
end architecture rtl;
