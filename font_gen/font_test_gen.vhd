-------------------------------------------------------------------------------
-- Listing 13.2
-- Code modified from https://academic.csuohio.edu/chu_p/rtl/fpga_vhdl.html
-- Updated 12/2/2020 by Kent Jones
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity font_test_gen is
  port (
    clk              : in std_logic;
    video_on         : in std_logic;
    char_num         : in std_logic_vector(11 downto 0);
    pixel_x, pixel_y : in std_logic_vector(9 downto 0);
    rgb_text         : out std_logic_vector(2 downto 0)
  );
end font_test_gen;

architecture arch of font_test_gen is
  signal rom_addr  : std_logic_vector(15 downto 0); --what 3 characters to access
  signal row_addr  : std_logic_vector(3 downto 0); --what rom row per character to access
  signal bit_addr  : std_logic_vector(2 downto 0);
  signal font_word_one : std_logic_vector(7 downto 0); --the font_words store the outputted row for each character (3)
  signal font_word_two : std_logic_vector(7 downto 0);
  signal font_word_three : std_logic_vector(7 downto 0);
  signal font_bit_one  : std_logic; --the font bits are determined by taking a modded x-axis and storing the font_word value from the index of that x
  signal font_bit_two  : std_logic; --basically, it tells the screen to draw a pixel or not
  signal font_bit_three  : std_logic;
begin

  -- compute the address in rom for character number char_num
  row_addr <= pixel_y(3 downto 0); --determines what row to select based on y axis
  rom_addr <= char_num & row_addr; --add what row to select to the 12 bit char_num so that we can know what row to select for all three numbers

  -- lookup the 8 bit font_words from the font rom. (Font words are 8 bits each)
  font_unit : entity work.font_rom
    port map(clk => clk, addr => rom_addr, dOne => font_word_one, dTwo => font_word_two, dThree => font_word_three);

  bit_addr <= not ( pixel_x(2 downto 0) ); --the bit address determines which pixel the current x-axis should access
  font_bit_one <= font_word_one(to_integer(unsigned(bit_addr))); --access the same bit index, but for each seperate digit
  font_bit_two <= font_word_two(to_integer(unsigned(bit_addr)));
  font_bit_three <= font_word_three(to_integer(unsigned(bit_addr)));

  -- rgb multiplexing circuit
  process ( video_on, font_bit_one, font_bit_two, font_bit_three, pixel_x, pixel_y )
  begin
    if video_on = '0' then
      rgb_text <= "010"; --blank (green is the arbitrary code for this)
    else --for each digit, check if it's within a very specific bound of the screen, and if the font_bit tells us to write, don't send out the green (blank) code
      if font_bit_three = '1' AND (to_integer(unsigned(pixel_x)) >= 576 AND to_integer(unsigned(pixel_x)) < 584) AND (to_integer(unsigned(pixel_y)) >= 32 AND to_integer(unsigned(pixel_y)) < 48) then
        rgb_text <= "000"; -- write
      elsif font_bit_two = '1' AND (to_integer(unsigned(pixel_x)) >= 584 AND to_integer(unsigned(pixel_x)) < 592) AND (to_integer(unsigned(pixel_y)) >= 32 AND to_integer(unsigned(pixel_y)) < 48) then
          rgb_text <= "000"; -- write
      elsif font_bit_one = '1' AND (to_integer(unsigned(pixel_x)) >= 592 AND to_integer(unsigned(pixel_x)) < 600) AND (to_integer(unsigned(pixel_y)) >= 32 AND to_integer(unsigned(pixel_y)) < 48) then
          rgb_text <= "000"; -- write
      else
        rgb_text <= "010"; -- blank (green is the arbitrary code for this)
      end if;
    end if;
  end process;
end arch;