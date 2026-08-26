#!/usr/bin/env bash
set -e

echo "======================================================"
echo "  كاشف — Kashif AI Car Diagnostic Report Assistant   "
echo "======================================================"
echo ""

if ! command -v node &> /dev/null; then
    echo "[ERROR] Node.js is not installed or not in PATH."
    exit 1
fi

if [ ! -d "node_modules" ]; then
    echo "[INFO] Installing dependencies..."
    npm install
fi

echo "[INFO] Starting Next.js development server on http://localhost:3000 ..."
npm run dev
