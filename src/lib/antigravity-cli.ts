import { exec, spawn } from "child_process";
import fs from "fs";
import path from "path";
import { KashifDiagnosticReport } from "./types";

export interface AgyStatusInfo {
  available: boolean;
  cliPath?: string;
  version?: string;
  engineName: string;
  statusNote: string;
}

/**
 * Locate the Antigravity CLI binary (agy.exe on Windows, agy on Linux/macOS)
 */
export function findAgyBinaryPath(): string | null {
  const isWindows = process.platform === "win32";
  const binaryName = isWindows ? "agy.exe" : "agy";

  // 1. Common user local app data paths
  const localAppData = process.env.LOCALAPPDATA || "";
  const userProfile = process.env.USERPROFILE || process.env.HOME || "";

  const candidatePaths = [
    path.join(localAppData, "agy", "bin", binaryName),
    path.join(userProfile, "AppData", "Local", "agy", "bin", binaryName),
    path.join(userProfile, ".local", "bin", binaryName),
    path.join("/usr/local/bin", binaryName),
    binaryName, // Check in PATH
  ];

  for (const p of candidatePaths) {
    if (p === binaryName) {
      // In PATH
      continue;
    }
    if (fs.existsSync(p)) {
      return p;
    }
  }

  return isWindows ? "agy.exe" : "agy";
}

/**
 * Check if Antigravity CLI is installed and operational
 */
export async function getAgyCliStatus(): Promise<AgyStatusInfo> {
  const binaryPath = findAgyBinaryPath() || "agy";

  return new Promise((resolve) => {
    exec(`"${binaryPath}" --help`, { timeout: 4000 }, (error, stdout) => {
      if (!error && (stdout.includes("Usage of agy") || stdout.includes("Usage: agy"))) {
        resolve({
          available: true,
          cliPath: binaryPath,
          engineName: "Antigravity CLI (agy)",
          statusNote: "محرك وكيل Antigravity المحلي جاهز ونشط",
        });
      } else {
        resolve({
          available: false,
          cliPath: binaryPath,
          engineName: "Antigravity CLI (agy)",
          statusNote: "أداة agy غير مثبتة في الخادم الحالي (يتم استخدام Gemini Cloud API)",
        });
      }
    });
  });
}

/**
 * Run prompt through Antigravity CLI in headless print mode
 */
export async function runAgyPrompt(
  promptText: string,
  timeoutMs: number = 25000
): Promise<string> {
  const binaryPath = findAgyBinaryPath() || "agy";

  return new Promise((resolve, reject) => {
    const child = spawn(
      binaryPath,
      ["--print", promptText, "--output-format", "json", "--dangerously-skip-permissions"],
      {
        stdio: ["ignore", "pipe", "pipe"],
        windowsHide: true,
      }
    );

    let stdoutData = "";
    let stderrData = "";

    const timer = setTimeout(() => {
      child.kill();
      reject(new Error("Antigravity CLI timed out after " + timeoutMs + "ms"));
    }, timeoutMs);

    child.stdout?.on("data", (data) => {
      stdoutData += data.toString();
    });

    child.stderr?.on("data", (data) => {
      stderrData += data.toString();
    });

    child.on("close", (code) => {
      clearTimeout(timer);
      if (code === 0 || stdoutData.trim().length > 0) {
        resolve(stdoutData);
      } else {
        reject(new Error(stderrData || `AGY exited with code ${code}`));
      }
    });

    child.on("error", (err) => {
      clearTimeout(timer);
      reject(err);
    });
  });
}

/**
 * Parse JSON report returned by AGY or fallback
 */
export function extractJsonFromAgyResponse(rawOutput: string): any {
  if (!rawOutput) return null;

  // 1. Direct JSON parse
  try {
    const parsed = JSON.parse(rawOutput);
    if (parsed.response && typeof parsed.response === "string") {
      try {
        return JSON.parse(parsed.response);
      } catch {
        // Continue
      }
    }
    if (parsed.reportId || parsed.faultCategories) {
      return parsed;
    }
  } catch {
    // Continue
  }

  // 2. Extract JSON code block
  const jsonMatch = rawOutput.match(/```(?:json)?\s*([\s\S]*?)\s*```/);
  if (jsonMatch && jsonMatch[1]) {
    try {
      return JSON.parse(jsonMatch[1]);
    } catch {
      // Continue
    }
  }

  // 3. Match outer brackets
  const firstBrace = rawOutput.indexOf("{");
  const lastBrace = rawOutput.lastIndexOf("}");
  if (firstBrace !== -1 && lastBrace > firstBrace) {
    try {
      return JSON.parse(rawOutput.slice(firstBrace, lastBrace + 1));
    } catch {
      // Ignore
    }
  }

  return null;
}
