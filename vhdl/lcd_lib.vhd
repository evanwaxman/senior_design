-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;

package LCD_LIB is

  -----------------------------------------------------------------------------
  -- COUNTER VALUES FOR GENERATING H_SYNC AND V_SYNC

  constant H_DISPLAY_END : integer := 800;
  constant HSYNC_BEGIN   : integer := 824;
  constant H_VERT_INC    : integer := 859;
  constant HSYNC_END     : integer := 896;
  constant H_MAX         : integer := 992;

  constant V_DISPLAY_END : integer := 481;
  constant VSYNC_BEGIN   : integer := 483;
  constant VSYNC_END     : integer := 493;
  constant V_MAX         : integer := 500;

  -----------------------------------------------------------------------------
  -- CONSTANTS FOR SIGNAL WIDTHS

  constant ROM_ADDR_WIDTH : integer := 8;
  subtype ROM_ADDR_RANGE is natural range ROM_ADDR_WIDTH-1 downto 0;

  constant COUNT_WIDTH : integer := 10;
  subtype COUNT_RANGE is natural range COUNT_WIDTH-1 downto 0;


end LCD_LIB;
