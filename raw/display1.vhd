----------------------------------------------------------------------------------
-- Ashwin Vallaban
-- Mini-Project SEM 6 Electronics & Tele-Communication
-- Fr. C. Rodrigues Institute of Technology
-- Project Open Sourced on GitHub:- https://github.com/ashvnv 
--
-- Create Date:    23:19:19 04/26/2022 
-- Module Name:    display1 - Behavioral 
-- Project Name:   FPGA Simple Ping-Pong game using Xilinx Spartan 3E 
-- Target Devices: Spartan 3E
-- Tool versions:  Xilinx 14.5
-- Description:    Simple Single Player Ping-Pong game written in VHDL and ran on Spartan 3E board.
--                 The game can be played with the in-built rotary switch. The game is displayed
--						 through the VGA configured with 640x480 resolution.
--						 A square shape is made which goes around the screen. A pad is given which is used to 
--                 reflect the cube back. The pad's position can be controlled using the
--                 in-built rotary switch. The cube and pad have same colours. The cube and pad changes the
--                 colour when the pad doesnot reflect the cube back, otherwise the colour remains the same.
--                 There are 4 different colours configured.
--                 To get more details, refer my GitHub's Readme for this project.     
-- Revision: rev1
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;



entity display1 is
    Port ( 
			  --for controlling the pad and reading the rotation direction
			  ROT_SHAFT_B : in STD_LOGIC;
			  ROT_SHAFT_A : in STD_LOGIC; 
			  
			  --for displaying the rotation direction (which determines pad movement direction)
			  LED0 : out STD_LOGIC;
			  LED1 : out STD_LOGIC;
			  
			  CLK : in  STD_LOGIC; -- for generating 25Mhz vga signals
           HSYNC : out  STD_LOGIC; -- vga HSYNC
           VSYNC : out  STD_LOGIC; -- vga VSYNC
           RGB : out  STD_LOGIC_VECTOR (2 downto 0)); -- vga RGB outputs
			  

			  
end display1;




architecture Behavioral of display1 is

	signal clk25 : std_logic := '0'; -- 25Mhz clock signal [pixel frequency]


   -- VGA timing signals number of pixels and lines defined here
   -- source: http://tinyvga.com/vga-timing/640x480@60Hz
	
	constant HD : integer := 639; -- Total horizontal Display pixels[0 - 639 = 640]
	constant HFP : integer := 16; -- Horizontal Front Porch pixels
	constant HSP : integer := 96; -- Horizontal Sync pulses pixels
	constant HBP : integer := 48; -- Horizontal Back Porch pixels
	
	constant VD : integer := 479; -- Total vertical display lines[0 - 479 = 480]
	constant VFP : integer := 10; -- Vertical front porch lines
	constant VSP : integer := 2; -- Vertical sync pulse lines
	constant VBP : integer := 33; -- vertical back porch lines
	-- VGA timing signal define end
	

   -- defines the current pixel and line position
	signal hPos : integer := 0;
	signal vPos : integer := 0;
	
	-- RBG turned off when the current pixel and line is outside the
	--     viewing area
	signal videoOn : std_logic := '0';
	
	
	-- The cube  traverses across the screen. Thresh gives the pixel value of 
   --       each side of the cube
	-- 				
	--             VLThresh
	--					_______
	-- 				|		|
	-- 	 HLThresh|     |HHThresh
	-- 				|     |
	-- 				-------
	--             VHThresh
	
	signal HHThresh : integer := 50; --width of the cube
	signal HLThresh : integer := 0;
	signal VHThresh : integer := 50;-- height of the cube
	signal VLThresh : integer := 0;
	

   -- defines the horizontal and vertical direction of the cube
	signal HDir : integer := 0; -- 0: right 1: left
	signal VDir : integer := 0; -- 0: down 1: up


   -- used for dividing the 50Mhz CLK by 2 to get 25Mhz
	signal count : integer :=0;
	
	-- used to read Rotary switch
	signal count2 : integer := 0;
	
	--for multi-colour
	signal colour : integer := 0;
	
	-- pad pixels defined here (width of the pad)
	--     					   __________________
	--    playerPadLThresh |                  | playerPadHThresh
	--     			        --------------------
	--                         
	signal playerPadHThresh : integer := 50;
	signal playerPadLThresh : integer := 0;
	

begin

-- divide the clock by 2 to get 25Mhz
clk_div:process(CLK)
begin
	if (CLK'event and CLK = '1') then
	clk25 <= not clk25;
	end if;
end process;


--defines the speed of cube traversing across the screen
--when the cube hits one of the edges (vertical or horizontal), it changes the direction
--when the direction is changed, the colour variable is increased by 1, this changes the color
--colour variable can go from 0 to 3 and then resets to 0
process(clk25) 
begin
if(rising_edge(clk25)) then
count <=count+1;
if(count = 100000) then
count <= 0;

      if (HDir = 0)then
		HHThresh <= HHThresh + 1;
		HLThresh <= HLThresh + 1;
		end if;
		
		if (VDir = 0) then
		VHThresh <= VHThresh + 1;
		VLThresh <= VLThresh + 1;
		end if;
		
		if (HDir = 1) then
		HHThresh <= HHThresh - 1;
		HLThresh <= HLThresh - 1;
		end if;
		
		if (VDir = 1) then
		VHThresh <= VHThresh - 1;
		VLThresh <= VLThresh - 1;
		end if;
		
		--direction change thresholds set below
		
		if (HHThresh > 638) then
			HDir <= 1;
		end if;
		
		if (HLThresh < 1) then
			HDir <= 0;
		end if;
		
		if (VHThresh > 478 and VDir = 0) then
			VDir <= 1;
			
			--here we are checking if the cube hits the pad. even if the cube comes in contact with the edge of the pad, it is a score
			if ((HHThresh < playerPadHThresh and HHThresh > playerPadLThresh) or (playerPadLThresh < HLThresh and HLThresh < playerPadHThresh))then
			-- here the player scored as the cube hit the pad
			-- score can be calculated and displayed
			
			else
			--here the cube did not hit the pad, change the colour
			colour <= colour + 1;
			
			end if;
			
		end if;
		
		if (VLThresh < 1) then
			VDir <= 0;
		end if;
		
		-- reset the colour if it is greater than 3
		if (colour > 3)then
		colour <= 0;
		end if;

end if;
end if;
end process;


-- for reading the rotary switch and getting the direction of rotation
process(clk25) 
begin
if(rising_edge(clk25)) then
count2 <=count2+1;
-- this delay is required to improve the movement of the pad
-- here the rotary switch mech chatter is not removed
-- rotary switch is too sensitive to rotation
if(count2 = 600000) then
count2 <= 0;

	--
	if (ROT_SHAFT_A = '0' and ROT_SHAFT_B = '1')then
	    LED1 <= '1';
		 
		 if (playerPadLThresh < 11)then
		 playerPadLThresh <= 0;
		 playerPadHThresh <= 50;
		 else
		 playerPadHThresh <= playerPadHThresh - 10;
		 playerPadLThresh <= playerPadLThresh - 10;
		 end if;

	elsif (ROT_SHAFT_A = '1' and ROT_SHAFT_B = '0')then
	    LED0 <= '1';
		 
		 if (playerPadHThresh > 629)then
		 playerPadHThresh <= 640;
		 playerPadLThresh <= 590;
		 else
		 playerPadHThresh <= playerPadHThresh + 10;
		 playerPadLThresh <= playerPadLThresh + 10;
		 end if;
		 
	else LED0 <= '0'; LED1 <= '0';
	end if;
end if;
end if;
end process;


--horizontal position
Horizontal_position_counter : process (clk25)
begin
	if (clk25'event and clk25 = '1')then
		if (hPos = (HD + HFP + HSP + HBP))then
			hPos <= 0;
		else
			hPos <= hPos + 1;
		end if;
	end if;
end process;

--vertical position
Vertical_position_counter : process (clk25, hPos)
begin
	if (clk25'event and clk25 = '1') then
		if (hPos = (HD + HFP + HSP + HBP)) then
			if (vPos = (VD + VFP + VSP + VBP)) then
				vPos <= 0;
			else
				vPos <= vPos + 1;
			end if;
		end if;
	end if;
end process;

--horizontal sync pulse
Horizontal_Synchronization:process(clk25, hPos)
begin
	if (clk25'event and clk25 = '1') then
		if ((hPos <= (HD + HFP)) OR (hPos > (HD + HFP + HSP))) then
			HSYNC <= '1';
		else
			HSYNC <= '0';
		end if;
	end if;
end process;

--vertical sync pulse
Vertical_Synchronization:process(clk25, vPos)
begin
	if (clk25'event and clk25 = '1') then
		if ((vPos <= (VD + VFP)) OR (vPos > (VD + VFP + VSP))) then
			VSYNC <= '1';
		else
			VSYNC <= '0';
		end if;
	end if;
end process;

--video on [if the pixel position is outside the viewing area, displayOn on is 0]
video_on:process(clk25,hPos, vPos)
begin
	if (clk25'event and clk25 = '1') then
		if (hPos <= HD and vPos < VD) then
			videoOn <= '1';
		else
			videoOn <= '0';
		end if;
	end if;
end process;

--draw the graphics on the screen
draw:process(clk25, hPos, vPos, videoOn)
begin
	if (clk25'event and clk25 = '1') then
	if (videoOn = '1') then

			if (hPos <= HHThresh and hPos >= HLThresh and vPos <= VHThresh and vPos >= VLThresh) or (vPos > 470 and hPos <= playerPadHThresh and hPos >= playerPadLThresh)then
			
			   -- interpret different colours
				if (colour = 0) then
					RGB <= "100";
				elsif (colour = 1) then
					RGB <= "010";
				elsif (colour = 2) then
					RGB <= "110";
				else 
					RGB <= "011";
				end if;
				
			else
				RGB <= "000";
			end if;
		else
			RGB <= "000";
		end if; 
	end if;
end process;

end Behavioral;

