const { withAppDelegate } = require('expo/config-plugins');

function withLiquidGlass(config) {
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

  return config;
}

module.exports = withLiquidGlass;
