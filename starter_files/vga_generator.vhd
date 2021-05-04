----------------------------------------------------------------------------------
-- Engineer:  Mike Field <hamster@snap.net.nz> 
-- Module:    vga_generator.vhd
-- 
-- Description: A test pattern generator for the Zedboard's VGA & HDMI interface
--
-- Feel free to use this how you see fit, and fix any errors you find :-)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_generator is
    Port ( clk   : in   STD_LOGIC;
           r     : out  STD_LOGIC_VECTOR (7 downto 0);
           g     : out  STD_LOGIC_VECTOR (7 downto 0);
           b     : out  STD_LOGIC_VECTOR (7 downto 0);
           color : in   STD_LOGIC_VECTOR (23 downto 0);
           xpos          : out unsigned(11 downto 0) := (others => '0');
           ypos         :  out unsigned(11 downto 0) := (others => '0');
           valid : out STD_LOGIC;
           de    : out  STD_LOGIC;
           vsync : out  STD_LOGIC := '0';
           hsync : out  STD_LOGIC := '0');
end vga_generator;

architecture Behavioral of vga_generator is
   signal blanking       : std_logic := '0';
   signal edge           : std_logic := '0';
   signal colour         : STD_LOGIC_VECTOR (23 downto 0);
   
   signal   hcounter    : unsigned(11 downto 0) := (others => '0');
   signal   vcounter    : unsigned(11 downto 0) := (others => '0');
   
   constant ZERO        : unsigned(11 downto 0) := (others => '0');
   signal   hVisible    : unsigned(11 downto 0);
   signal   hStartSync  : unsigned(11 downto 0);
   signal   hEndSync    : unsigned(11 downto 0);
   signal   hMax        : unsigned(11 downto 0);
   signal   hSyncActive : std_logic := '1';
   
   signal   vVisible    : unsigned(11 downto 0);
   signal   vStartSync  : unsigned(11 downto 0);
   signal   vEndSync    : unsigned(11 downto 0);
   signal   vMax        : unsigned(11 downto 0);
   signal   vSyncActive : std_logic := '1';
   
   
   -- Colours converted using The RGB -> YCbCr converter app found on Google Gadgets 
                                                                        --  Y   Cb  Cr
   constant C_BLACK      : std_logic_vector(23 downto 0) := x"000000";  --  16 128 128
   constant C_RED        : std_logic_vector(23 downto 0) := x"FF0000";  --  81  90 240
   constant C_GREEN      : std_logic_vector(23 downto 0) := x"00FF00";  -- 172  42  27
   constant C_BLUE       : std_logic_vector(23 downto 0) := x"0000FF";  --  32 240 118
   constant C_WHITE      : std_logic_vector(23 downto 0) := x"FFFFFF";  -- 234 128 128
   
begin   
   -- Set the video mode to 1280x720x60Hz (75MHz pixel clock needed)
--   hVisible    <= ZERO + 1280;
--   hStartSync  <= ZERO + 1280+72;
--   hEndSync    <= ZERO + 1280+72+80;
--   hMax        <= ZERO + 1280+72+80+216-1;
   
--   vVisible    <= ZERO + 720;
--   vStartSync  <= ZERO + 720+3;
--   vEndSync    <= ZERO + 720+3+5;
--   vMax        <= ZERO + 720+3+5+22-1;
   
-- 1280x1024x60Hz @ 108MHz Pixel clock 
     hVisible    <= ZERO + 1280;
     hStartSync  <= ZERO + 1280+48;
     hEndSync    <= ZERO + 1280+48+112;
     hMax        <= ZERO + 1280+48+112+248-1;
   
     vVisible    <= ZERO + 1024;
     vStartSync  <= ZERO + 1024+1;
     vEndSync    <= ZERO + 1024+1+3;
     vMax        <= ZERO + 1024+1+3+38-1;

   -- Set the video mode to 1920x1080x60Hz (150MHz pixel clock needed)
--   hVisible    <= ZERO + 1920;
--   hStartSync  <= ZERO + 1920+88;
--   hEndSync    <= ZERO + 1920+88+44;
--   hMax        <= ZERO + 1920+88+44+148-1;
--   vSyncActive <= '1';

--   vVisible    <= ZERO + 1080;
--   vStartSync  <= ZERO + 1080+4;
--   vEndSync    <= ZERO + 1080+4+5;
--   vMax        <= ZERO + 1080+4+5+36-1;
--   hSyncActive <= '1';

colour_proc: process(hcounter,vcounter, color)
  begin
 

      colour(23 downto 16) <= std_logic_vector(color(23 downto 16));
      colour(15 downto 8) <= std_logic_vector(color(15 downto 8));
      colour(7 downto 0) <= std_logic_vector(color(7 downto 0));

  end process;

clk_process: process (clk)
   begin
      if rising_edge(clk) then 

         if vcounter >= vVisible or hcounter >= hVisible then 
			--- VALID GOES HERE?
            R <= (others => '0');
            G <= (others => '0');
            B <= (others => '0');
            de <= '0';
            valid <= '0';
         else
            R  <= colour(23 downto 16);
            G  <= colour(15 downto  8);
            B  <= colour( 7 downto  0);
            de <= '1';
            valid <= '1';
         end if;
              
         -- Generate the sync Pulses
         if vcounter = vStartSync then 
            vSync <= vSyncActive;
         elsif vCounter = vEndSync then
            vSync <= not(vSyncActive);
         end if;

         if hcounter = hStartSync then 
            hSync <= hSyncActive;
         elsif hCounter = hEndSync then
            hSync <= not(hSyncActive);
         end if;

            -- Advance the position counters
         IF hCounter = hMax  THEN
            -- starting a new line
            hCounter <= (others => '0');
            IF vCounter = vMax THEN
               vCounter <= (others => '0');
            ELSE
               vCounter <= vCounter + 1;
               ypos <= vCounter;
            END IF;
         ELSE
            hCounter <= hCounter + 1;
            xpos <= hCounter;
         end if;
      end if;
   end process;
   
end Behavioral;

