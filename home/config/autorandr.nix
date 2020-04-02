let
  embeddedScreen = "00ffffffffffff0006af362000000000001b0104a51f117802fbd5a65334b6250e505400000001010101010101010101010101010101e65f00a0a0a040503020350035ae100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe004231343051414e30322e30200a00d2";
in
{
  enable = true;
  #postswitch = {
  #  "notify-i3" = "${pkgs.i3}/bin/i3-msg restart";
  #};
  profiles = {
    "embedded" = {
      fingerprint.eDP1 = embeddedScreen;
      config.eDP1 = {
        enable = true;
        primary = true;
        mode = "2560x1440";
        position = "0x0";
        rate = "60.01";
      };
    };
    "office-lg4k" = {
      fingerprint = {
        eDP1 = embeddedScreen;
        DP1 = "00ffffffffffff001e6d0777c6e90500031d0104b53c22789e3e31ae5047ac270c50542108007140818081c0a9c0d1c08100010101014dd000a0f0703e803020650c58542100001a286800a0f0703e800890650c58542100001a000000fd00383d1e8738000a202020202020000000fc004c472048445220344b0a20202001b80203197144900403012309070783010000e305c000e3060501023a801871382d40582c450058542100001e565e00a0a0a029503020350058542100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000029";
      };
      config = {
        eDP1.enable = false;
        DP1 = {
          enable = true;
          primary = true;
          position = "0x0";
          mode = "3840x2160";
          gamma = "1.0:0.909:0.909";
          rate = "60.00";
        };
      };
    };
    "home-lg4k" = {
      fingerprint = {
        DP0 = "00ffffffffffff001e6d0777c6e90500031d0104b53c22789e3e31ae5047ac270c50542108007140818081c0a9c0d1c08100010101014dd000a0f0703e803020650c58542100001a286800a0f0703e800890650c58542100001a000000fd00383d1e8738000a202020202020000000fc004c472048445220344b0a20202001b80203197144900403012309070783010000e305c000e3060501023a801871382d40582c450058542100001e565e00a0a0a029503020350058542100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000029";
      };
      config = {
        DP0 = {
          enable = true;
          primary = true;
          position = "0x0";
          mode = "3840x2160";
          gamma = "1.0:0.909:0.909";
          rate = "60.00";
        };
      };
    };
  };
}