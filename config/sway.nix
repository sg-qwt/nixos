{ config, self }:
let
  wallpaper = self + "/resources/wallpapers/wr.jpg";
in
''
  ### Variables
  set $mod Mod4

  set $left h
  set $down j
  set $up k
  set $right l

  set $term xfce4-terminal

  # Your preferred application launcher
  # Note: pass the final command to swaymsg so that the resulting window can be opened
  # on the original workspace that the command was run on.
  # set $menu dmenu_path | dmenu | xargs swaymsg exec --

  ### Output configuration
  # You can get the names of your outputs by running: swaymsg -t get_outputs
  # output "Dell Inc. DELL U2718QM MYPFK89J15HL" mode 3840x2160@60Hz scale 2 pos 0 0
  # output "Unknown GX259F 0x00000000" mode 1920x1080@360.001Hz pos 1920 0

  output * bg ${wallpapaer} fill

  seat seat0 xcursor_theme ${config.home.pointerCursor.name} ${toString config.home.pointerCursor.size}

  default_border pixel
  default_floating_border pixel

  ### Idle configuration
  #
  # Example configuration:
  #
  # exec swayidle -w \
  #          timeout 300 'swaylock -f -c 000000' \
  #          timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
  #          before-sleep 'swaylock -f -c 000000'
  #
  # This will lock your screen after 300 seconds of inactivity, then turn off
  # your displays after another 300 seconds, and turn your screens back on when
  # resumed. It will also lock your screen before your computer goes to sleep.

  ### Input configuration
  input "4152:6166:SteelSeries_SteelSeries_Rival_106_Gaming_Mouse" {
      accel_profile "flat" # disable mouse acceleration (enabled by default; to set it manually, use "adaptive" instead of "flat")
      pointer_accel 0 # set mouse sensitivity (between -1 and 1)
  }


  ### Key bindings
  #
  # Basics:
  #
      # Start a terminal
      bindsym $mod+Shift+Return exec $term
      bindsym $mod+Return exec switch-terminal

      # Emacs
      bindsym $mod+e exec switch-emacs

      # Kill focused window
      bindsym $mod+Shift+q kill

      # Start your launcher
      bindsym $mod+d exec wofi --show=drun

      # screenshot
      bindsym $mod+p exec grim -g "$(slurp)"

      # Drag floating windows by holding down $mod and left mouse button.
      # Resize them with right mouse button + $mod.
      # Despite the name, also works for non-floating windows.
      # Change normal to inverse to use left mouse button for resizing and right
      # mouse button for dragging.
      floating_modifier $mod normal

      # Reload the configuration file
      bindsym $mod+Shift+c reload

      # Exit sway (logs you out of your Wayland session)
      bindsym $mod+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'
  #
  # Moving around:
  #
      # Move your focus around
      bindsym $mod+$left focus left
      bindsym $mod+$down focus down
      bindsym $mod+$up focus up
      bindsym $mod+$right focus right

      # Move the focused window with the same, but add Shift
      bindsym $mod+Shift+$left move left
      bindsym $mod+Shift+$down move down
      bindsym $mod+Shift+$up move up
      bindsym $mod+Shift+$right move right
  #
  # Workspaces:
  #
      # Switch to workspace
      bindsym $mod+1 workspace number 1
      bindsym $mod+2 workspace number 2
      bindsym $mod+3 workspace number 3
      bindsym $mod+4 workspace number 4
      bindsym $mod+5 workspace number 5
      bindsym $mod+6 workspace number 6
      bindsym $mod+7 workspace number 7
      bindsym $mod+8 workspace number 8
      # Move focused container to workspace
      bindsym $mod+Shift+1 move container to workspace number 1
      bindsym $mod+Shift+2 move container to workspace number 2
      bindsym $mod+Shift+3 move container to workspace number 3
      bindsym $mod+Shift+4 move container to workspace number 4
      bindsym $mod+Shift+5 move container to workspace number 5
      bindsym $mod+Shift+6 move container to workspace number 6
      bindsym $mod+Shift+7 move container to workspace number 7
      bindsym $mod+Shift+8 move container to workspace number 8
      # Note: workspaces can have any name you want, not just numbers.
      # We just use 1-10 as the default.
      bindsym $mod+tab workspace back_and_forth
  #
  # Layout stuff:
  #
      # You can "split" the current object of your focus with
      # $mod+b or $mod+v, for horizontal and vertical splits
      # respectively.
      bindsym $mod+b splith
      bindsym $mod+v splitv

      # Switch the current container between different layout styles
      bindsym $mod+s layout stacking
      bindsym $mod+w layout tabbed
      bindsym $mod+Shift+s layout toggle split

      # Make the current focus fullscreen
      bindsym $mod+f fullscreen

      # Toggle the current focus between tiling and floating mode
      bindsym $mod+Shift+space floating toggle

      # Swap focus between the tiling area and the floating area
      bindsym $mod+space focus mode_toggle

      # Move focus to the parent container
      bindsym $mod+a focus parent
  #
  # Scratchpad:
  #
      # Sway has a "scratchpad", which is a bag of holding for windows.
      # You can send windows there and get them back later.

      # Move the currently focused window to the scratchpad
      bindsym $mod+Shift+minus move scratchpad

      # Show the next scratchpad window or hide the focused scratchpad window.
      # If there are multiple scratchpad windows, this command cycles through them.
      bindsym $mod+minus scratchpad show
  #
  # Resizing containers:
  #
  mode "resize" {
      # left will shrink the containers width
      # right will grow the containers width
      # up will shrink the containers height
      # down will grow the containers height
      bindsym $left resize shrink width 10px
      bindsym $down resize grow height 10px
      bindsym $up resize shrink height 10px
      bindsym $right resize grow width 10px

      # Return to default mode
      bindsym Return mode "default"
      bindsym Escape mode "default"
  }
  bindsym $mod+r mode "resize"

  #
  # Status Bar:
  #
  # Read `man 5 sway-bar` for more information about this section.
  bar {
      swaybar_command waybar
  }

  include /etc/sway/config.d/*

  exec fcitx5 -d
''
