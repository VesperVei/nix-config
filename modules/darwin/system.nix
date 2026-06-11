{myvars, ...}: {
  time.timeZone = "Asia/Shanghai";
  # open touch's sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = myvars.username;
    defaults = {
      NSGlobalDomain = {
        # Appearance (主题样式)
        AppleInterfaceStyle = "Dark"; # dark mode
        "com.apple.swipescrolldirection" = true; # enable natural scrolling(default to true)
        "com.apple.sound.beep.feedback" = 0; # 禁用按音量键时的“哔哔”反馈声
        # 对于光标移速度
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
        KeyRepeat = 3; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)
        # 打字反人类行为纠正系列
        NSAutomaticCapitalizationEnabled = false; # 禁用自动大写
        NSAutomaticDashSubstitutionEnabled = false; # 禁用智能破折号
        NSAutomaticPeriodSubstitutionEnabled = false; # 禁用智能句号（双击空格变句号）
        NSAutomaticQuoteSubstitutionEnabled = false; # 禁用智能引号
        NSAutomaticSpellingCorrectionEnabled = false; # 禁用自动拼写纠正
        # 展开保存面板
        NSNavPanelExpandedStateForSaveMode = true; # expand save panel by default(保存文件时的路径选择/文件名输入页)
        NSNavPanelExpandedStateForSaveMode2 = true;
      };
      CustomUserPreferences = {
        # 设置系统默认截图工具（Cmd + Shift + 3/4）保存路径
        "com.apple.screencapture" = {
          location = "~/Desktop";
          type = "jpeg";
        };
        # 关闭 Apple 的个性化广告追踪
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;

        "com.apple.finder" = {
          ShowStatusBar = true; # 显示状态栏
          ShowPathbar = true; # 显示路径栏
          FXDefaultSearchScope = "SCcf"; # 搜索当前文件夹
        };
        "com.apple.desktopservices" = {
          # 极客神技：禁止在网络驱动器和外接 U 盘上生成恶心的 .DS_Store 文件
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.screensaver" = {
          # Require password immediately after sleep or screen saver begins
          askForPassword = 1;
          askForPasswordDelay = 0;
        };
        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = 0; # Click wallpaper to reveal desktop
        };
      };
      # 控制 Mac 启动或锁屏时的登录界面行为
      loginwindow = {
        GuestEnabled = false; # disable guest user
        SHOWFULLNAME = true; # show full name in login window
      };
    };
  };
}
