/** @type {import('@bacons/apple-targets/app.plugin').ConfigFunction} */
module.exports = (config) => ({
  type: "keyboard",
  name: "KyxKeyboard",
  displayName: "Kyx",
  bundleIdentifier: ".keyboard",
  deploymentTarget: "16.4",
  // Dùng chung App Group với app chứa (khai báo ở app.json → ios.entitlements).
  entitlements: {
    "com.apple.security.application-groups":
      config.ios.entitlements["com.apple.security.application-groups"],
  },
});
