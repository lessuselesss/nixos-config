{...}: {
  services.karabiner-elements = {
    enable = true;
    configuration = {
      profiles = [
        {
          complex_modifications.rules = [
            {
              description = "YABAI SPACE: MIRROR (Flip)                                                                                                     [⌥] option    +   [⌘] command  +  { f }";
              manipulators = [
                {
                  from = {
                    key_code = "x";
                    modifiers.mandatory = ["shift" "option"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m space --mirror x-axis";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "y";
                    modifiers.mandatory = ["shift" "option"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m space --mirror y-axis";}];
                  type = "basic";
                }
              ];
            }
            {
              description = "YABAI SPACE: MOVE (Next/Prev)                                                                                                [⇧] shift       +   [⌥] option        +  { n, p }";
              manipulators = [
                {
                  from = {
                    key_code = "n";
                    modifiers.mandatory = ["shift" "option"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --space next";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "p";
                    modifiers.mandatory = ["shift" "option"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --space prev";}];
                  type = "basic";
                }
              ];
            }
            {
              description = "YABAI SPACE: ROTATE                                                                                                                                                             [⇧] shift       +   [⌥] option        +  { ⏴j  ;⏵ }";
              manipulators = [
                {
                  from = {
                    key_code = "semicolon";
                    modifiers.mandatory = ["shift" "option"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m space --rotate 270";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "j";
                    modifiers.mandatory = ["shift" "option"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m space --rotate 90";}];
                  type = "basic";
                }
              ];
            }
            {
              description = "YABAI WINDOW: MOVE (Split)                                                                                                                                  [⌃] control   +   [⌘] command  +  { ⏴j ⏶k l⏷ ;⏵ }";
              manipulators = [
                {
                  from = {
                    key_code = "j";
                    modifiers.mandatory = ["control" "command"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --warp west";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "k";
                    modifiers.mandatory = ["control" "command"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --warp north";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "l";
                    modifiers.mandatory = ["control" "command"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --warp south";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "semicolon";
                    modifiers.mandatory = ["control" "command"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --warp east";}];
                  type = "basic";
                }
              ];
            }
            {
              description = "YABAI WINDOW: SWAP                                                                                                                                                      [⌥] option    +   [⌘] command  +  { ⏴j ⏶k l⏷ ;⏵ }";
              manipulators = [
                {
                  from = {
                    key_code = "j";
                    modifiers.mandatory = ["option" "command"];
                  };
                  to = [{shell_command = "/usr/local/bin/yabai -m window --swap west";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "k";
                    modifiers.mandatory = ["option" "command"];
                  };
                  to = [{shell_command = "/usr/local/bin/yabai -m window --swap north";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "l";
                    modifiers.mandatory = ["option" "command"];
                  };
                  to = [{shell_command = "/usr/local/bin/yabai -m window --swap south";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "semicolon";
                    modifiers.mandatory = ["option" "command"];
                  };
                  to = [{shell_command = "/usr/local/bin/yabai -m window --swap east";}];
                  type = "basic";
                }
              ];
            }
            {
              description = "YABAI WINDOW: SIZE (Up)                                                                                                                              [⇧] shift       +   [⌘] command  +  { ⏴j ⏶k l⏷ ;⏵ }";
              manipulators = [
                {
                  from = {
                    key_code = "j";
                    modifiers.mandatory = ["shift" "command"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --resize bottom_right:-100:0";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "k";
                    modifiers.mandatory = ["shift" "command"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --resize bottom_left:0:-100";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "l";
                    modifiers.mandatory = ["shift" "command"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --resize bottom_left:0:100";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "semicolon";
                    modifiers.mandatory = ["shift" "command"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --resize bottom_right:100:0";}];
                  type = "basic";
                }
              ];
            }
            {
              description = "YABAI WINDOW: SIZE (Down)                                                                                                                                                                                                   [⌃] control   +   [⌘] command  +  [⇧] shift +  { ⏴j ⏶k l⏷ ;⏵ }";
              manipulators = [
                {
                  from = {
                    key_code = "j";
                    modifiers.mandatory = ["control" "shift" "command"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --resize bottom_right:-100:0";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "k";
                    modifiers.mandatory = ["control" "shift" "command"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --resize top_right:0:100";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "l";
                    modifiers.mandatory = ["control" "shift" "command"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --resize bottom_right:0:-100";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "semicolon";
                    modifiers.mandatory = ["control" "shift" "command"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --resize bottom_left:100:0";}];
                  type = "basic";
                }
              ];
            }
            {
              description = "YABAI WINDOW: FOCUS                                                                                                                     [⌥] option    +   { ⏴j ⏶k l⏷ ;⏵ }";
              manipulators = [
                {
                  from = {
                    key_code = "j";
                    modifiers.mandatory = ["option"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --focus west";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "k";
                    modifiers.mandatory = ["option"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --focus north";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "l";
                    modifiers.mandatory = ["option"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --focus south";}];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "semicolon";
                    modifiers.mandatory = ["option"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --focus east";}];
                  type = "basic";
                }
              ];
            }
            {
              description = "YABAI WINDOW: TOGGLE(Float)                                                                                            [⌥] option    +   [⌘] command  +  { f }";
              manipulators = [
                {
                  from = {
                    key_code = "f";
                    modifiers.mandatory = ["option" "command"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --toggle float --grid 4:4:1:1:2:2";}];
                  type = "basic";
                }
              ];
            }
            {
              description = "YABAI WINDOW: TOGGLE(Fullscreen)                                                                                                  [⇧] shift       +   [⌘] option        +  { m }";
              manipulators = [
                {
                  from = {
                    key_code = "m";
                    modifiers.mandatory = ["shift" "option"];
                  };
                  to = [{shell_command = "/run/current-system/sw/bin/yabai -m window --toggle zoom-fullscreen";}];
                  type = "basic";
                }
              ];
            }
          ];
          name = "Default profile";
          selected = true;
          virtual_hid_keyboard.keyboard_type_v2 = "ansi";
        }
      ];
      selected = true;
      title = "lessuseless Karabiner Configuration";
      virtual_hid_keyboard.keyboard_type_v2 = "ansi";
    };
  };
}