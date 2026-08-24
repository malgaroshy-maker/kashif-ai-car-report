const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const nextDir = path.join(rootDir, '.next');
const publicDir = path.join(rootDir, 'public');

console.log('🚀 Preparing Cloudflare Worker Assets output...');

// 1. Copy .next/server/app/index.html to .next/index.html
const srcIndex = path.join(nextDir, 'server', 'app', 'index.html');
const destIndex = path.join(nextDir, 'index.html');

if (fs.existsSync(srcIndex)) {
  fs.copyFileSync(srcIndex, destIndex);
  console.log('✓ Created .next/index.html');
}

// 2. Copy .next/server/app/_not-found.html to .next/404.html
const src404 = path.join(nextDir, 'server', 'app', '_not-found.html');
const dest404 = path.join(nextDir, '404.html');

if (fs.existsSync(src404)) {
  fs.copyFileSync(src404, dest404);
  console.log('✓ Created .next/404.html');
}

// 3. Copy public assets (parts, icons, SVGs) into .next
if (fs.existsSync(publicDir)) {
  fs.cpSync(publicDir, nextDir, { recursive: true, force: true });
  console.log('✓ Copied public assets into .next');
}

console.log('✨ Cloudflare Worker Assets preparation complete!');
