{...}: {
  services.yabai = {
    enable = true;
    config = {
      # General settings
      layout = "bsp";
      insert_feedback_color = "0xffd75f5f";
      split_ratio = 0.50;
      split_type = "auto";
      auto_balance = false;

      # Window Spacing
      top_padding = "3";
      bottom_padding = "3";
      left_padding = "3";
      right_padding = "3";
      window_gap = "3";

      # Window Properties
      window_shadow = "float";
    };
  };
}
