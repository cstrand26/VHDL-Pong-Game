-------------------------------------------------------------------------------
-- ball Generator
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity ball_gen is
  port (
    clk              : in std_logic; -- clock 
    video_on         : in std_logic; -- vga synch signal
    pixel_tick       : in std_logic; -- pixel tick from vga synch generator
    pixel_x, pixel_y : in std_logic_vector(9 downto 0); -- counters from vga synch     
    red              : out std_logic_vector(3 downto 0);-- output red for mapping to vga
    green            : out std_logic_vector(3 downto 0);-- output green for mapping to vga
    blue             : out std_logic_vector(3 downto 0); -- output blue for mapping to vga

    btnU           : in std_logic; -- paddle up
    btnD           : in std_logic; -- paddle down
    btnC           : in std_logic; -- reset
    score          : out std_logic

  );
end ball_gen;

architecture ball_gen of ball_gen is

  signal ball_r   : std_logic_vector(3 downto 0) := (others => '0'); -- input red bits for the ball  
  signal ball_g   : std_logic_vector(3 downto 0) := (others => '0'); -- input green bits for the ball
  signal ball_b   : std_logic_vector(3 downto 0) := (others => '0'); -- input blue bits for the ball  

  signal red_reg, red_next: std_logic_vector(3 downto 0) := (others => '0');
  signal green_reg, green_next: std_logic_vector(3 downto 0) := (others => '0');
  signal blue_reg, blue_next: std_logic_vector(3 downto 0) := (others => '0');   
  
  -- position of the ball
  signal ball_xl, ball_yt, ball_xr, ball_yb : integer := 0;
  -- position of the paddle
  signal paddle_xl, paddle_yt, paddle_xr, paddle_yb : integer := 0;
  -- if the paddle or ball have moved positions
  signal update_pos_ball, update_pos_paddle : std_logic := '0';
  -- direction of paddle's movement, either -1, 0, or 1
  signal paddle_dir_y : integer := 0;
  -- offset to be subtracted for counter for ball to speed up it's movement
  signal speed_increase : integer := 0;
begin

  -- generate the signal update_pos that will move the ball
  process ( video_on )
    variable counter_ball, counter_paddle : integer := 0;
  begin
    if rising_edge(video_on) then
      -- increase counters
      counter_ball := counter_ball + 1;
      counter_paddle := counter_paddle + 1;
      -- if ball counter has exceeded the limit, update ball position
      if counter_ball > (480 - speed_increase) then
        counter_ball := 0;
        update_pos_ball <= '1';
      else
        update_pos_ball <= '0';
      end if;
      -- if paddle counter has exceed the limit, update paddle position
      if counter_paddle > 60 then
        counter_paddle := 0;
        update_pos_paddle <= '1';
      else
        update_pos_paddle <= '0';
      end if;
    end if;
  end process;

  -- compute the position and direction of ball 
  process (update_pos_ball, btnC, ball_xr, ball_xl, ball_yt, ball_yb, paddle_xr, paddle_yt, paddle_yb, paddle_dir_y)
    -- signals for animating the ball
    variable dir_x : integer := 4;
    variable dir_y : integer := 4;  
    variable x : integer := 320;
    variable y : integer := 240;
    -- signal for if a score has occured
    variable scored : std_logic := '0';    
  begin
    -- to reset everything
    if btnC = '1' then
      -- reset speed of ball by setting counter offset to 0
      speed_increase <= 0;
      -- change ball directions back to default
      dir_x := 4;
      dir_y := 4;
      -- reset ball's position back to default
      x := 320;
      y := 240;
      -- send signal to update score
      scored := '1';
    else
    -- update the x, y direction sychronously on rising edge
    -- of the update_pos (update position) signal
      if rising_edge(update_pos_ball) then 
        scored := '0';
        -- Mux to choose the next x position
        --   whenever you have a mux, make sure ALL 
        --   ouptut signals are set in ALL cases.
        if (ball_xr > 636) and (dir_x = 4) then
          -- bounce off right
          dir_x := -4;
          x := 629;
        elsif (ball_xl < 4) and (dir_x = -4) then
          -- stop the ball
          dir_x := 0;
          dir_y := 0;    
          x := 0;
        -- checks if ball is in range of paddle
        elsif (ball_xl < paddle_xr) and (dir_x = -4) and (ball_yt < paddle_yb + 1) and (ball_yb > paddle_yt + 1) then
          -- bounce the ball back
          dir_x := 4;
          -- add or subtract the paddles y-speed to the balls y-speed
          dir_y := dir_y + paddle_dir_y;
          x := paddle_xr;
          -- send signal to update score
          scored := '1';
          -- if speed offset has not reached it's maximum, increase it
          if (speed_increase < 420) then
            speed_increase <= speed_increase + 1;
          end if;
        else
          -- keep going same direction
          dir_x := dir_x; 
          x := x + dir_x;
        end if;
              
        -- Mux to choose next y position
        --   whenever you have a mux, make sure ALL 
        --   ouptut signals are set in ALL cases.          
        if (ball_yb > (480 - dir_y)) and (dir_y > 0) then
          -- bounce off bottom 
          dir_y := -dir_y;
          y := 470;
        elsif (ball_yt < (0 - dir_y)) and (dir_y < 0) then
          -- bounce off top
          dir_y := -dir_y;   
          y := 0; 
        else  
          -- keep going same direction      
          dir_y := dir_y;
          y := y + dir_y;                
        end if;  
      end if;
      
    end if;
    -- ball position now relies on x,y and is not "fixed"
    ball_xl <= x;  
    ball_yt <= y;
    ball_xr <= x + 10;
    ball_yb <= y + 10;

    score <= scored;
  
  end process;

    -- compute the position and direction of paddle 
  process (update_pos_paddle, btnC, btnU, btnD, paddle_xr, paddle_xl, paddle_yt, paddle_yb)
    -- signals for animating the paddle
    variable dir_y : integer := 0;  
    variable x : integer := 0;
    variable y : integer := 200;       
  begin
    -- reset the paddles position
    if btnC = '1' then
      y := 200;
    else
      -- update the x, y direction sychronously on rising edge
      -- of the update_pos (update position) signal
      if rising_edge(update_pos_paddle) then 
              
        -- Mux to choose next y position
        --   whenever you have a mux, make sure ALL 
        --   ouptut signals are set in ALL cases.
        -- if the paddle can go down, and only the down button is pressed          
        if (paddle_yb < 480) and btnU = '0' and btnD = '1' then
          -- go down
          dir_y := 1;
          y := y + dir_y;
        -- if the paddle can go up, and only the up button is pressed
        elsif (paddle_yt > 0) and btnU = '1' and btnD = '0' then
          -- go up
          dir_y := -1;   
          y := y + dir_y;
        else  
          -- stop moving      
          dir_y := 0;
          y := y;

        end if;

      end if; 
    end if;
    -- paddle position now relies on x,y and is not "fixed"
    paddle_xl <= x;  
    paddle_yt <= y;
    paddle_xr <= x + 10;
    paddle_yb <= y + 80;
    paddle_dir_y <= dir_y;
  
  end process;

  process (update_pos_ball, ball_xl, ball_yb, paddle_yb)
  begin
    if rising_edge(update_pos_ball) then
      -- the x position of the ball determines the red value of the ball and paddle color
      if ball_xl < 40 then
        ball_r <= "0000";
      elsif ball_xl < 80 then
        ball_r <= "0001";
      elsif ball_xl < 120 then
        ball_r <= "0010";
      elsif ball_xl < 160 then
        ball_r <= "0011";
      elsif ball_xl < 200 then
        ball_r <= "0100";
      elsif ball_xl < 240 then
        ball_r <= "0101";
      elsif ball_xl < 280 then
        ball_r <= "0110";
      elsif ball_xl < 320 then
        ball_r <= "0111";
      elsif ball_xl < 360 then
        ball_r <= "1000";
      elsif ball_xl < 400 then
        ball_r <= "1001";
      elsif ball_xl < 440 then
        ball_r <= "1010";
      elsif ball_xl < 480 then
        ball_r <= "1011";
      elsif ball_xl < 520 then
        ball_r <= "1100";
      elsif ball_xl < 560 then
        ball_r <= "1101";
      elsif ball_xl < 600 then
        ball_r <= "1110";
      else
        ball_r <= "1111";
      end if;

      -- the y position of the ball determines the green value of the ball and paddle color
      if ball_yb < 30 then
        ball_g <= "0000";
      elsif ball_yb < 60 then
        ball_g <= "0001";
      elsif ball_yb < 90 then
        ball_g <= "0010";
      elsif ball_yb < 120 then
        ball_g <= "0011";
      elsif ball_yb < 150 then
        ball_g <= "0100";
      elsif ball_yb < 180 then
        ball_g <= "0101";
      elsif ball_yb < 210 then
        ball_g <= "0110";
      elsif ball_yb < 240 then
        ball_g <= "0111";
      elsif ball_yb < 270 then
        ball_g <= "1000";
      elsif ball_yb < 300 then
        ball_g <= "1001";
      elsif ball_yb < 330 then
        ball_g <= "1010";
      elsif ball_yb < 360 then
        ball_g <= "1011";
      elsif ball_yb < 390 then
        ball_g <= "1100";
      elsif ball_yb < 420 then
        ball_g <= "1101";
      elsif ball_yb < 450 then
        ball_g <= "1110";
      else
        ball_g <= "1111";
      end if;

      -- the y position of the paddle determines the blue value of the ball and paddle color
      if paddle_yb < 25 then
        ball_b <= "0000";
      elsif paddle_yb < 50 then
        ball_b <= "0001";
      elsif paddle_yb < 75 then
        ball_b <= "0010";
      elsif paddle_yb < 100 then
        ball_b <= "0011";
      elsif paddle_yb < 125 then
        ball_b <= "0100";
      elsif paddle_yb < 150 then
        ball_b <= "0101";
      elsif paddle_yb < 175 then
        ball_b <= "0110";
      elsif paddle_yb < 200 then
        ball_b <= "0111";
      elsif paddle_yb < 225 then
        ball_b <= "1000";
      elsif paddle_yb < 250 then
        ball_b <= "1001";
      elsif paddle_yb < 275 then
        ball_b <= "1010";
      elsif paddle_yb < 300 then
        ball_b <= "1011";
      elsif paddle_yb < 325 then
        ball_b <= "1100";
      elsif paddle_yb < 350 then
        ball_b <= "1101";
      elsif paddle_yb < 375 then
        ball_b <= "1110";
      else
        ball_b <= "1111";
      end if;
    end if;
   
   end process;

  -- process to generate output colors for the ball and paddle          
  process (pixel_x, pixel_y, ball_xl, ball_xr, ball_yt, ball_yb, paddle_xl, paddle_yt, paddle_xr, paddle_yb)
  begin
    -- the borders of the ball and paddle
    if ((unsigned(pixel_x) > ball_xl) and (unsigned(pixel_x) < ball_xr) and
      (unsigned(pixel_y) > ball_yt) and (unsigned(pixel_y) < ball_yb)) or
      ((unsigned(pixel_x) > paddle_xl) and (unsigned(pixel_x) < paddle_xr) and
      (unsigned(pixel_y) > paddle_yt) and (unsigned(pixel_y) < paddle_yb)) then

      red_next   <= ball_r;
      green_next <= ball_g;
      blue_next  <= ball_b;
    else
      -- background color opposite of ball color
      red_next   <= not ball_r;
      green_next <= not ball_g;
      blue_next  <= not ball_b;
    end if;
  end process;

  -- generate r,g,b registers
  process (video_on, pixel_tick, red_next, green_next, blue_next)
  begin
    if rising_edge(pixel_tick) then
      if (video_on = '1') then
        red_reg   <= red_next;
        green_reg <= green_next;
        blue_reg  <= blue_next;
      else
        red_reg   <= "0000";
        green_reg <= "0000";
        blue_reg  <= "0000";
      end if;
    end if;
  end process;

  -- generate the output colors
  red <= red_reg;
  green <= green_reg;
  blue <= blue_reg;

end ball_gen;