# { 
#   config, 
#   pkgs, 
#   ... 
#   }:

# {
#   services = {
#     yabai = {
#       enable = true;
#       config = {
#         layout = "bsp";
#         # external_bar = "off:40:0";
#         # menubar_opacity = "1.0";
#         # mouse_follows_focus = "off";
#         # focus_follows_mouse = "off";
#         # display_arrangement_order = [ "default" ];
        
#         # insert_feedback_color = "0xffd75f5f";
#         # split_ratio = 0.50;
#         # split_type = "auto";
#         # auto_balance = false;

#         # # Window Spacing
#         top_padding = "3";
#         bottom_padding = "3";
#         left_padding = "3";
#         right_padding = "3";
#         window_gap = "3";

#         # # Window Properties
#         # window_origin_display = "default";
#         # window_placement = "second_child";
#         # window_zoom_persist = true;
#         # window_shadow = true;
#         # window_animation_duration = 0.0;
#         # window_animation_easing = "ease_out_circ";
#         # window_opacity_duration = 0.0;
#         # active_window_opacity = 1.0;
#         # normal_window_opacity = 0.90;
#         # window_opacity = false;
#         window_shadow = "float";
#       };
#     };
#   };
# }