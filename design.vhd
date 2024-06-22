library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity goertzel_filter is
    generic (
        coef : signed(19 downto 0) := to_signed(19447, 20);
        coef_div : signed(19 downto 0) := to_signed(10000, 20)
    );
    port (
        input_signal : in unsigned (11 downto 0);
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        magnitude : out signed(39 downto 0)
    );
end entity goertzel_filter;

architecture behavioural of goertzel_filter is
    signal q0, q1, q2 : signed(39 downto 0);
    signal x : signed(11 downto 0); -- 12-bit signed for internal computation
    signal sample_cnt : integer range 0 to 134 := 0;
    signal result : signed(39 downto 0);
begin
    process (clk, rst)
    begin
        if rst = '1' then
            q0 <= (others => '0');
            q1 <= (others => '0');
            q2 <= (others => '0');
            sample_cnt <= 0;
            result <= (others => '0');
        elsif rising_edge(clk) then
            x <= signed(input_signal); -- Convert 12-bit unsigned to signed
            q0 <= x + coef * q1 / coef_div - q2;
            q2 <= q1;
            q1 <= q0;
            if sample_cnt = 134 then
                result <= q1 * q1 + q2 * q2 - coef * q2 * q1 / coef_div;
                sample_cnt <= 0;
            else
                sample_cnt <= sample_cnt + 1;
            end if;
        end if;
    end process;

    magnitude <= result;
end architecture behavioural;
