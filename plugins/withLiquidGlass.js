const { withAppDelegate, withXcodeProject } = require('expo/config-plugins');
const path = require('path');
const fs = require('fs');

function withLiquidGlass(config) {
  // Modify AppDelegate: configure native UITabBar appearance at startup
  config = withAppDelegate(config, (cfg) => {
    const contents = cfg.modResults.contents;
    const marker = '#import "ExpoAppDelegate.h"';

    if (contents.includes(marker)) {
      const block = `
@interface UITabBarController (LiquidGlassConfig)
@end

@implementation UITabBarController (LiquidGlassConfig)
+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if (@available(iOS 26.0, *)) {
      UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
      [appearance configureWithDefaultBackground];
      appearance.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
      appearance.backgroundColor = [UIColor colorWithWhite:0.06 alpha:0.2];
      [[UITabBar appearance] setStandardAppearance:appearance];
      [[UITabBar appearance] setScrollEdgeAppearance:appearance];
      [[UITabBar appearance] setTranslucent:YES];
    }
  });
}
@end
`;
      cfg.modResults.contents = contents.replace(marker, marker + block);
    }
    return cfg;
  });

  // Copy Swift/ObjC native module files to ios/ and add to Xcode project
  config = withXcodeProject(config, (cfg) => {
    const iosDir = cfg.modRequest.platformProjectRoot;
    const pairs = [
      ['LiquidGlassView.swift', 'LiquidGlassView.swift'],
      ['LGTabBarManager.m', 'LGTabBarManager.m'],
    ];

    for (const [srcName, dstName] of pairs) {
      const srcPath = path.join(__dirname, srcName);
      const dstPath = path.join(iosDir, dstName);
      if (fs.existsSync(srcPath) && !fs.existsSync(dstPath)) {
        fs.copyFileSync(srcPath, dstPath);
        cfg.modResults.addSourceFile(dstName, null, null);
      }
    }
    return cfg;
  });

  return config;
}

module.exports = withLiquidGlass;
