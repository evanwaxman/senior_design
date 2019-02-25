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


  ------------------------------------------------------------------------------
  -- CONSTANTS FOR CALIBRATION POINTS



  constant CAL_POINT_0_X_MIN : integer := 68; 
  constant CAL_POINT_0_X_MAX : integer := 77;
  constant CAL_POINT_0_Y_MIN : integer := 115;
  constant CAL_POINT_0_Y_MAX : integer := 125;

  constant CAL_POINT_1_X_MIN : integer := 395;
  constant CAL_POINT_1_X_MAX : integer := 405;
  constant CAL_POINT_1_Y_MIN : integer := 403;
  constant CAL_POINT_1_Y_MAX : integer := 413;

  constant CAL_POINT_2_X_MIN : integer := 675;
  constant CAL_POINT_2_X_MAX : integer := 685;
  constant CAL_POINT_2_Y_MIN : integer := 235;
  constant CAL_POINT_2_Y_MAX : integer := 245;



end LCD_LIB;
