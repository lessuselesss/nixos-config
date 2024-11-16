{ config, pkgs, ... }:

{
  # Enable karabiner-elements
  services.karabiner.enable = true;

  # Karabiner configuration options
  services.karabiner.config = ''
    {
      "title": "lessuseless Karabiner Configuration",
      "rules": [
        {
            "description": "YABAI WINDOW: FOCUS              |    [⌥] option    +  { ⏴j, ⏶k, ⏷l, ⏵; }",
            "manipulators": [
                {
                    "from": {
                        "key_code": "j",
                        "modifiers": { "mandatory": ["option"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --focus west" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "k",
                        "modifiers": { "mandatory": ["option"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --focus north" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "l",
                        "modifiers": { "mandatory": ["option"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --focus south" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "semicolon",
                        "modifiers": { "mandatory": ["option"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --focus east" }],
                    "type": "basic"
                }
            ]
        },
        {
            "description": "YABAI WINDOW: FOCUS              |    [fn] function +  {n,p,tab} ",
            "manipulators": [
                {
                    "from": {
                        "key_code": "n",
                        "modifiers": { "mandatory": ["fn"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m query --windows --space | /usr/local/bin/jq '.[-1].id' | xargs -I{} /run/current-system/sw/bin/yabai -m window --focus {}" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "p",
                        "modifiers": { "mandatory": ["fn"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m query --windows --space | /usr/local/bin/jq '.[1].id' | xargs -I{} /run/current-system/sw/bin/yabai -m window --focus {}" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "tab",
                        "modifiers": { "mandatory": ["fn"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --focus next" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "tab",
                        "modifiers": { "mandatory": ["fn", "shift"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --focus prev" }],
                    "type": "basic"
                }
            ]
        },
        {
            "description": "YABAI WINDOW: SIZE (UP)          |    [⇧] shift       +   [⌘] command  +  { ⏴j, ⏶k, ⏷l, ⏵; }",
            "manipulators": [
                {
                    "from": {
                        "key_code": "j",
                        "modifiers": { "mandatory": ["shift", "command"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --resize bottom_left:-100:0" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "k",
                        "modifiers": { "mandatory": ["shift", "command"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --resize top_left:0:-100" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "l",
                        "modifiers": { "mandatory": ["shift", "command"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --resize bottom_left:0:100" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "semicolon",
                        "modifiers": { "mandatory": ["shift", "command"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --resize bottom_right:100:0" }],
                    "type": "basic"
                }
            ]
        },
        {
            "description": "YABAI WINDOW: SIZE (DOWN)    |    [⇧] shift      +   [⌘] command   +  [⌃] control +  { ⏴j, ⏶k, ⏷l, ⏵; }",
            "manipulators": [
                {
                    "from": {
                        "key_code": "h",
                        "modifiers": { "mandatory": ["fn", "shift", "control"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --resize bottom_right:-100:0" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "j",
                        "modifiers": { "mandatory": ["fn", "shift", "control"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --resize top_right:0:100" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "k",
                        "modifiers": { "mandatory": ["fn", "shift", "control"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --resize bottom_right:0:-100" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "l",
                        "modifiers": { "mandatory": ["fn", "shift", "control"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --resize bottom_left:100:0" }],
                    "type": "basic"
                }
            ]
        },
        {
            "description": "YABAI WINDOW: SWAP                |    [⌥] option    +   [⌘] command  +  { ⏴j, ⏶k, ⏷l, ⏵; }",
            "manipulators": [
                {
                    "from": {
                        "key_code": "j",
                        "modifiers": { "mandatory": ["option", "command"] }
                    },
                    "to": [{ "shell_command": "/usr/local/bin/yabai -m window --swap west" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "k",
                        "modifiers": { "mandatory": ["option", "command"] }
                    },
                    "to": [{ "shell_command": "/usr/local/bin/yabai -m window --swap north" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "l",
                        "modifiers": { "mandatory": ["option", "command"] }
                    },
                    "to": [{ "shell_command": "/usr/local/bin/yabai -m window --swap south" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "semicolon",
                        "modifiers": { "mandatory": ["option", "command"] }
                    },
                    "to": [{ "shell_command": "/usr/local/bin/yabai -m window --swap east" }],
                    "type": "basic"
                }
            ]
        },
        {
            "description": "YABAI WINDOW: WARP                |    [⌃] control   +   [⌘] command  +  { ⏴j, ⏶k, ⏷l, ⏵; }",
            "manipulators": [
                {
                    "from": {
                        "key_code": "j",
                        "modifiers": { "mandatory": ["control", "command"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --warp west" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "k",
                        "modifiers": { "mandatory": ["control", "command"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --warp north" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "l",
                        "modifiers": { "mandatory": ["control", "command"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --warp south" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "semicolon",
                        "modifiers": { "mandatory": ["control", "command"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m window --warp east" }],
                    "type": "basic"
                }
            ]
        },
        {
            "description": "YABAI SPACE: layout [fn + {b,f,}]",
            "manipulators": [
                {
                    "from": {
                        "key_code": "b",
                        "modifiers": { "mandatory": ["fn"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m space --layout bsp" }],
                    "type": "basic"
                },
                {
                    "from": {
                        "key_code": "f",
                        "modifiers": { "mandatory": ["fn"] }
                    },
                    "to": [{ "shell_command": "/run/current-system/sw/bin/yabai -m space --layout float" }],
                    "type": "basic"
                }
            ]
        }
      ]
    }
  '';
}