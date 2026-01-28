#!/bin/bash
# Setup modern theme for ubuntu user

# Create XFCE config directories
mkdir -p /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml
mkdir -p /home/ubuntu/.config/openbox

# Copy openbox config
cp /etc/openbox-rc.xml /home/ubuntu/.config/openbox/rc.xml

# Configure XFCE appearance
cat > /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Arc-Dark"/>
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>
    <property name="DoubleClickTime" type="int" value="400"/>
    <property name="DoubleClickDistance" type="int" value="5"/>
    <property name="DndDragThreshold" type="int" value="8"/>
    <property name="CursorBlink" type="bool" value="true"/>
    <property name="CursorBlinkTime" type="int" value="1200"/>
    <property name="SoundThemeName" type="string" value="default"/>
    <property name="EnableEventSounds" type="bool" value="false"/>
    <property name="EnableInputFeedbackSounds" type="bool" value="false"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="int" value="-1"/>
    <property name="Antialias" type="int" value="1"/>
    <property name="Hinting" type="int" value="1"/>
    <property name="HintStyle" type="string" value="hintslight"/>
    <property name="RGBA" type="string" value="rgb"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="CanChangeAccels" type="bool" value="false"/>
    <property name="ColorPalette" type="string" value="black:white:gray50:red:purple:blue:light blue:green:yellow:orange:lavender:brown:goldenrod4:dodger blue:pink:light green:gray10:gray30:gray75:gray90"/>
    <property name="FontName" type="string" value="Noto Sans 10"/>
    <property name="MonospaceFontName" type="string" value="Monospace 10"/>
    <property name="IconSizes" type="string" value=""/>
    <property name="KeyThemeName" type="string" value=""/>
    <property name="ToolbarStyle" type="string" value="icons"/>
    <property name="ToolbarIconSize" type="int" value="3"/>
    <property name="MenuImages" type="bool" value="true"/>
    <property name="ButtonImages" type="bool" value="true"/>
    <property name="MenuBarAccel" type="string" value="F10"/>
    <property name="CursorThemeName" type="string" value=""/>
    <property name="CursorThemeSize" type="int" value="0"/>
    <property name="DecorationLayout" type="string" value="menu:minimize,maximize,close"/>
  </property>
</channel>
EOF

# Configure XFCE panel appearance
cat > /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="32"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
      </property>
      <property name="background-style" type="uint" value="0"/>
      <property name="background-alpha" type="uint" value="100"/>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="applicationsmenu"/>
    <property name="plugin-2" type="string" value="tasklist"/>
    <property name="plugin-3" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-4" type="string" value="systray"/>
    <property name="plugin-5" type="string" value="clock"/>
  </property>
</channel>
EOF

# Configure desktop background
cat > /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value=""/>
          <property name="rgba1" type="array">
            <value type="double" value="0.203922"/>
            <value type="double" value="0.266667"/>
            <value type="double" value="0.309804"/>
            <value type="double" value="1.000000"/>
          </property>
          <property name="rgba2" type="array">
            <value type="double" value="0.152941"/>
            <value type="double" value="0.156863"/>
            <value type="double" value="0.133333"/>
            <value type="double" value="1.000000"/>
          </property>
        </property>
      </property>
    </property>
  </property>
  <property name="desktop-icons" type="empty">
    <property name="style" type="int" value="2"/>
    <property name="icon-size" type="uint" value="48"/>
    <property name="use-custom-font-size" type="bool" value="true"/>
    <property name="font-size" type="double" value="10.000000"/>
  </property>
</channel>
EOF

# Create Desktop directory
mkdir -p /home/ubuntu/Desktop

# Create Firefox desktop shortcut
cat > /home/ubuntu/Desktop/firefox.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Name=Firefox Web Browser
Comment=Browse the World Wide Web
Exec=firefox %u
Terminal=false
Type=Application
Icon=firefox
Categories=Network;WebBrowser;
StartupNotify=true
EOF

# Create VS Code desktop shortcut
cat > /home/ubuntu/Desktop/code.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Name=Visual Studio Code
Comment=Code Editing. Redefined.
Exec=/usr/bin/code --no-sandbox --unity-launch %F
Terminal=false
Type=Application
Icon=com.visualstudio.code
Categories=Development;IDE;
StartupNotify=false
EOF

# Create Terminal desktop shortcut
cat > /home/ubuntu/Desktop/terminal.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Name=Terminal
Comment=Terminal Emulator
Exec=xfce4-terminal
Terminal=false
Type=Application
Icon=utilities-terminal
Categories=System;TerminalEmulator;
StartupNotify=false
EOF

# Make desktop files executable and trusted
chmod +x /home/ubuntu/Desktop/*.desktop

# Configure plank dock
mkdir -p /home/ubuntu/.config/plank/dock1/launchers

# Add Firefox to dock
cat > /home/ubuntu/.config/plank/dock1/launchers/firefox.dockitem << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/firefox.desktop
EOF

# Add VS Code to dock
cat > /home/ubuntu/.config/plank/dock1/launchers/code.dockitem << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/code.desktop
EOF

# Add Terminal to dock
cat > /home/ubuntu/.config/plank/dock1/launchers/terminal.dockitem << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/xfce4-terminal.desktop
EOF

# Add File Manager to dock
cat > /home/ubuntu/.config/plank/dock1/launchers/thunar.dockitem << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/thunar.desktop
EOF

# Configure plank appearance
mkdir -p /home/ubuntu/.config/plank/dock1
cat > /home/ubuntu/.config/plank/dock1/settings << 'EOF'
[PlankDockPreferences]
DockItems=firefox.dockitem;;code.dockitem;;terminal.dockitem;;thunar.dockitem
HideMode=3
IconSize=48
Position=3
Theme=Default
EOF

# Set ownership
chown -R ubuntu:ubuntu /home/ubuntu/.config
chown -R ubuntu:ubuntu /home/ubuntu/Desktop

# Fix permissions
chmod -R 755 /home/ubuntu/.config
