-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.std_logic_unsigned.all;

entity pong_top is
    port (
        -- system clock
        CLK100MHZ : in STD_LOGIC;

        -- vga inputs and outputs
        Hsync, Vsync :  out STD_LOGIC; -- horizontal and Vertical Synch
        vgaRed :        out STD_LOGIC_VECTOR(3 downto 0); -- Red bits
        vgaGreen :      out STD_LOGIC_VECTOR(3 downto 0); -- Green bits
        vgaBlue :       out STD_LOGIC_VECTOR(3 downto 0); -- Blue bits
        
        -- switches and LEDs
        btnU, btnD, btnC, btnL : in STD_LOGIC; -- 5 button inputs
        sw :            in STD_LOGIC_VECTOR (15 downto 0); -- 16 switch inputs
        LED :           out std_logic_vector (15 downto 0); -- 16 leds above switches
        an :            out std_logic_vector (3 downto 0); -- Controls four 7-seg displays
        seg :           out std_logic_vector(6 downto 0); -- 6 leds per display
        dp :            out std_logic -- 1 decimal point per display 
    );
end pong_top;

architecture pong_top of pong_top is
    signal clk, reset    : std_logic;
    signal pixel_x, pixel_y     : std_logic_vector(9 downto 0); --VGA stuff
    signal video_on, pixel_tick : std_logic;

    signal rgb_reg : std_logic_vector(2 downto 0); --From kbrd example. This register will hold the vga color values to be output to the console
    signal numCounter : std_logic_vector(11 downto 0) := "000000000000"; --These two are for number counting
    signal rgb_text : std_logic_vector(2 downto 0); --From vga_kbrd_top example

    signal ball_r : std_logic_vector(3 downto 0); --rgb code for ball
    signal ball_g : std_logic_vector(3 downto 0);
    signal ball_b : std_logic_vector(3 downto 0);

    shared variable  numCounterVar : std_logic_vector(11 downto 0); --Incrementing a variable instead of a signal

    signal score : std_logic;
begin
    clk   <= CLK100MHZ; -- system clock
    reset <= btnL; -- reset signal for vga driver
    LED   <= sw; -- drive LED's from switches
      
    reset <= btnL; -- set reset signal with bntL
      
    -- Turn off the 7-segment LEDs
    an  <= "1111"; -- wires supplying power to 4 7-seg displays
    seg <= "1111111"; -- wires connecting each of 7 * 4 segments to ground
    dp  <= '1'; -- wire connects decimal point to ground    
      
    -- instantiate VGA sync circuit
    vga_sync_unit : entity work.vga_sync
        port map(
            clk => clk, reset => reset, hsync => Hsync,
            vsync => Vsync, video_on => video_on,
            pixel_x => pixel_x, pixel_y => pixel_y,
            p_tick => pixel_tick
        );
    -- Generates ball, paddle, and background colors and locations
    ball_gen_unit : entity work.ball_gen
        port map(
            clk      => clk,
            video_on => video_on,
            pixel_tick => pixel_tick, --TODO possibly remove the extra pixel tick here
            pixel_x => pixel_x, pixel_y => pixel_y,
            red => ball_r, green => ball_g, blue => ball_b,
            btnU => btnU, btnD => btnD, btnC => btnC,
            score => score
        );

        -- Modified from kbrd example. Will take in numCounter (12 bits). Each 4 bit group represents a different digit
    font_gen_unit : entity work.font_test_gen
        port map(
            clk => CLK100MHZ, video_on => video_on,
            char_num => numCounter,
            pixel_x => pixel_x, pixel_y => pixel_y,
            rgb_text => rgb_text --Outputs when to display text. If the color code is green: 010 (arbitrary) there is no text to be displayed
        );

        --This process increases the numCounterVar whenever the ball hits the paddle.
        --It also checks if any of the 4 bits is >=10 so that we can effectively handle it like it's base 10
        process (score, btnC)
        begin
            if rising_edge(score) then --Rick gave me this idea! I forgot that 4 bits goes up to 16 and not 10 
                numCounterVar := numCounterVar + 1; --increment the score count
                if (numCounterVar(3 downto 0) >= "1010") then --bound each binary digit to base 10
                    numCounterVar(11 downto 4) := numCounterVar(11 downto 4) + 1;
                    numCounterVar(3 downto 0) := "0000";
                end if;
                if (numCounterVar(7 downto 4) >= "1010")  then --bound this for the next base
                    numCounterVar(11 downto 8) := numCounterVar(11 downto 8) + 1;
                    numCounterVar(7 downto 4) := "0000";
                end if;
                if (numCounterVar(11 downto 8) >= "1010") or (btnC = '1')then --if we reset or get to 1000, go back to 0
                    numCounterVar := "000000000000";
                end if;
            end if;
        end process;

        --This process tells vgaRGB what to display
        process (CLK100MHZ)
        begin
            if rising_edge(CLK100MHZ) then
                numCounter <= numCounterVar; --copy numCounterVar to numCounter every tick. This will go to the font_test_gen component
                if (pixel_tick = '1') then
                    if not (rgb_text = "010") then --If the arbitrary color code coming from font_test_gen is not green, that means that this specific pixel has a text element so we should prioritize drawing this over the ball, background, or paddle (ball_gen_unit)
                        vgaRed <= not ball_r;
                        vgaGreen <= not ball_g;
                        vgaBlue <= not ball_b;
                    else --If there is no text needing to be written, draw the ball, paddle, and background from the signals changed in ball_gen_unit
                        vgaRed <= ball_r;
                        vgaGreen <= ball_g;
                        vgaBlue <= ball_b;
                    end if;
                end if;
            end if;
        end process;

      
end pong_top;