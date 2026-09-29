library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity tb_programmable_counter is

end entity;

architecture simulation of tb_programmable_counter is
    constant N          : positive :=8;
    constant CLK_PERIOD : TIME := 10 ns;

    signal clk          : STD_LOGIC := '0';
    signal rst_n        : STD_LOGIC := '1';
    signal enable : STD_LOGIC := '0';
    signal load : STD_LOGIC := '0';
    signal load_value : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0') ;
    signal limit_value : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
    signal count : STD_LOGIC_VECTOR(N-1 downto 0) ;
    signal limit_pulse : STD_LOGIC ;
begin
    uut : entity work.programmable_counter
    generic map (
        N => N
    )
    port map (
            clk         => clk,
            rst_n       => rst_n,
            enable      => enable,
            load        => load,
            load_value  => load_value,
            limit_value => limit_value,
            count       => count,
            limit_pulse => limit_pulse
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
    begin
        rst_n <='1';
        wait for 1 ns;
        rst_n <='0';
        wait for 1 ns;
        limit_value <= STD_LOGIC_VECTOR(to_unsigned(4,N));
        load_value <= STD_LOGIC_VECTOR(to_unsigned(2,N));
        --asenkron reset test

        assert count = STD_LOGIC_VECTOR(to_unsigned(0,N))
            report "Reset Error:"
            severity FAILURE;
        
        assert limit_pulse='0'
            report "Limit_pulse is not zero"
            severity FAILURE;
        
        wait until falling_edge(clk);
        rst_n <= '1';

        load <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;

        assert count = STD_LOGIC_VECTOR(to_unsigned(2,N)) 
            report "load error: expected count is 2"
            severity FAILURE;
        
        load <='0';
        enable <='1';

        wait until rising_edge(clk);
        wait for 1 ns;

        assert count = STD_LOGIC_VECTOR(to_unsigned(3,N))
            report "enable error: expected count is 3"
            severity FAILURE;

        wait until rising_edge(clk);
        wait for 1 ns;

        assert count = STD_LOGIC_VECTOR(to_unsigned(4,N))
            report "enable error: expected count is 4"
            severity FAILURE;
        
        wait until rising_edge(clk);
        wait for 1 ns;
        
            assert count = STD_LOGIC_VECTOR(to_unsigned(0,N))
            report "enable error: expected count is 0"
            severity FAILURE;
        
        assert limit_pulse = '1'
            report "LIMIT ERROR: expected limit_pulse = 1"
            severity failure;

        -- Pulse sonraki clock'ta temizlenmeli
        wait until rising_edge(clk);
        wait for 1 ns;

        assert count = std_logic_vector(to_unsigned(1, N))
            report "COUNT ERROR: expected count = 1"
            severity failure;

        assert limit_pulse = '0'
            report "PULSE ERROR: limit_pulse lasted longer than one cycle"
            severity failure;

        -- Enable kapatıldığında değer korunmalı
        enable <= '0';

        wait until rising_edge(clk);
        wait for 1 ns;

        assert count = std_logic_vector(to_unsigned(1, N))
            report "ENABLE ERROR: count changed while enable was zero"
            severity failure;

        -- Load ve enable aynı anda 1: load öncelikli
        load_value <= std_logic_vector(to_unsigned(3, N));
        load       <= '1';
        enable     <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;

        assert count = std_logic_vector(to_unsigned(3, N))
            report "PRIORITY ERROR: load did not override enable"
            severity failure;

        -- Load bırakılınca 3'ten devam etmeli
        load <= '0';

        wait until rising_edge(clk);
        wait for 1 ns;

        assert count = std_logic_vector(to_unsigned(4, N))
            report "COUNT ERROR: counter did not continue from load value"
            severity failure;

        report "ALL TESTS PASSED" severity note;

        stop;
        wait;
        
        
    end process;
    

end architecture;