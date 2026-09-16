library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

entity tb_fsmvhdl is
    
end entity;

architecture simulation of tb_fsmvhdl is
    constant CLK_PERIOD : time := 10 ns;
    signal clk : STD_LOGIC := '0';
    signal rst_n : STD_LOGIC := '1';
    signal valid : STD_LOGIC := '0';
    signal bit_in : STD_LOGIC := '0';
    signal match : STD_LOGIC;
begin
    uut : entity work.sequence_detector_1011
        port map (
            clk => clk,
            rst_n => rst_n,
            valid => valid,
            bit_in => bit_in,
            match => match

        );
    clock_process : process
    begin
        while TRUE  loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;
    


    stimulus_process : process
    
        procedure send_bit (
            constant input_bit : in std_logic;
            constant expected_match : in std_logic
        ) is
        begin
            wait until falling_edge(clk);

            bit_in <= input_bit;
            valid <='1';

            wait until rising_edge(clk);
            wait for 1 ns;

            assert match=expected_match
                report
                    "ERROR: bit_in=" &
                    std_logic'image(input_bit) &
                    ", match=" &
                    std_logic'image(match) &
                    ", expected=" &
                    std_logic'image(expected_match)
                severity error;

        end procedure;


    begin

        rst_n  <='0';
        valid  <='0';
        bit_in <='0';

        wait until rising_edge(clk);
        wait until rising_edge(clk);

        wait until rising_edge(clk);
        rst_n <= '1';

        --1011011
        send_bit('1','0');
        send_bit('0','0');
        send_bit('1','0');
        send_bit('1','1');

        send_bit('0','0');
        send_bit('1','0');
        send_bit('1','1');
        
        wait until falling_edge(clk);

        valid <='0';
        bit_in <= '0';
        
        report "ALL TEST COMPLETED";
        finish;
        
        
    end process;
end architecture;