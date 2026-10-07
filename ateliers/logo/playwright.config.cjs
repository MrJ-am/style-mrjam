const { defineConfig } = require('@playwright/test');
const fs = require('node:fs');
const systemChromium = process.env.CHROMIUM_PATH || (fs.existsSync('/usr/bin/chromium') ? '/usr/bin/chromium' : undefined);
module.exports = defineConfig({
  testDir: './browser-tests',
  timeout: 30000,
  expect: { timeout: 5000 },
  workers: 2,
  reporter: [['list'], ['json', { outputFile: 'verification/browser-results.json' }]],
  use: { baseURL: 'http://127.0.0.1:4187', viewport: { width: 1440, height: 1000 }, trace: 'retain-on-failure' },
  webServer: { command: 'python3 -m http.server 4187 --bind 127.0.0.1 --directory dist', url: 'http://127.0.0.1:4187', reuseExistingServer: false },
  projects: [
    { name: 'chromium', use: { browserName: 'chromium', launchOptions: { executablePath: systemChromium, args: ['--no-sandbox'] } } },
    { name: 'firefox', use: { browserName: 'firefox' } }
  ]
});
