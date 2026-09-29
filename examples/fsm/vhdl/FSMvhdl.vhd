library ieee;
use ieee.std_logic_1164.all;


entity sequence_detector_1011 is
    port (
        clk   : in std_logic;
        rst_n : in std_logic;
        valid : in std_logic;
        bit_in  : in  std_logic;
        match   : out std_logic
    
    );
end entity sequence_detector_1011;

architecture rtl of sequence_detector_1011 is
    type state_t is(
        IDLE,
        S1,
        S10,
        S101
    );

    signal current_state : state_t;
    signal next_state    : state_t;
    signal detected_comb : STD_LOGIC;
    signal matched_reg   : STD_LOGIC;

begin

    match <= matched_reg;

    --Next state combinational logic

    combinational_process : process (current_state, valid, bit_in)
    begin
        next_state <= current_state;
        detected_comb <= '0';
        
        if valid ='1' then
            case current_state is
                when IDLE =>
                    
                    if bit_in='1' then
                        next_state <= S1;
                        
                    else
                         next_state <= IDLE;
                    end if;

                when S1 =>
                    if bit_in='1' then
                        next_state <= S1;
                    else
                        next_state <= S10;
                    end if;
                
                when S10 =>
                    if bit_in='1' then
                        next_state <=S101;
                    else
                        next_state <= IDLE;
                    end if;
                
                when S101 =>
                    if bit_in='1' then
                        detected_comb <= '1';
                        next_state <=S1;
                    else
                        next_state <= S10;    
                    end if;

                when others =>
                    next_state <= IDLE;
                    detected_comb <= '0';
                    null;
            end case;
            
        end if ;
        
    end process;

    sequential_process : process (clk,rst_n)
    begin
        if rst_n='0' then
            current_state <= IDLE;
            matched_reg <= '0';
        elsif rising_edge(clk) then
            current_state <= next_state;
            matched_reg <=detected_comb;

        end if;
    end process;
end architecture rtl;

