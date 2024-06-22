library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

-- Testbench for the Goertzel filter

entity tb_goertzel_filter is
end tb_goertzel_filter;

architecture Behavioral of tb_goertzel_filter is
  component goertzel_filter is
      generic (
          coef : signed(19 downto 0) := to_signed(19447, 20);
          coef_div : signed(19 downto 0) := to_signed(10000, 20)
      );
      port (
          input_signal : in unsigned (11 downto 0);
          clk : in std_logic;
          rst : in std_logic;
          magnitude : out signed(39 downto 0)
      );
  end component;

  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal magnitude : signed(39 downto 0);
  signal data_signal : unsigned(11 downto 0);
  constant coef_value : signed(19 downto 0) := to_signed(19447, 20);
  constant coef_div_value : signed(19 downto 0) := to_signed(10000, 20);

begin
  DUT: goertzel_filter
    generic map(
      coef => coef_value,
      coef_div => coef_div_value
    )
    port map (
      clk => clk,
      rst => rst,
      input_signal => data_signal,
      magnitude => magnitude
    );

  clk_gen: process
  begin
    while true loop
      clk <= '0';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
    end loop;
  end process;

  process
    variable line_v : line;
    file read_file : text;
    variable file_data : unsigned(11 downto 0);
    variable file_data_str : string(1 to 16);
    constant file_name : string := "signal_ones.txt";

  begin
    file_open(read_file, file_name, read_mode);
    while not endfile(read_file) loop
      readline(read_file, line_v);
      read(line_v, file_data_str);
      file_data := to_unsigned(to_integer(unsigned(conv_std_logic_vector(to_integer(string'("0000" & file_data_str(1 to 11))), 12))), 12);
      report "file_data: " & integer'image(to_integer(file_data));
      if file_data = to_unsigned(1, 12) then
        rst <= '1';
      else
        rst <= '0';
        data_signal <= resize(file_data(11 downto 0), data_signal'length);
      end if;
      wait until rising_edge(clk);
    end loop;
    file_close(read_file);
    wait;
  end process;

end architecture Behavioral;
