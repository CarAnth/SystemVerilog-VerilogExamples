library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

entity tb_sequence_detector_1011 is
end entity tb_sequence_detector_1011;

architecture sim of tb_sequence_detector_1011 is

    constant CLK_PERIOD : time := 10 ns;
    signal clk : STD_LOGIC := '0';
    signal rst_n : STD_LOGIC := '1';
    signal valid : STD_LOGIC := '0';
    signal bit_in : STD_LOGIC := '0';
    signal match : STD_LOGIC;
    
begin
    uut:entity work.sequence_detector_1011
        port map (
            clk     => clk,
            rst_n   => rst_n,
            valid   => valid, 
            bit_in  => bit_in, 
            match   => match
        );
    
        clock_process : process 
        begin
            while TRUE loop
                clk <= '0';
                wait for CLK_PERIOD/2;
                
                clk <= '1';
                wait for CLK_PERIOD/2;
            end loop;
            
        end process;

   stimulus_process : process

    procedure apply_reset is
    begin
        -- rst_n, valid ve bit_in sinyallerini ayarla
        rst_n   <='0';
        valid   <='0';
        bit_in  <='0';
        -- İki rising edge boyunca reset uygula
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        -- Falling edge'de reset'i kaldır
        WAIT Until falling_edge(clk);
        rst_n <= '1';
        
    end procedure apply_reset;

begin

    apply_reset;

    report "RESET COMPLETED" severity note;

    wait;

end process stimulus_process;

end architecture sim;