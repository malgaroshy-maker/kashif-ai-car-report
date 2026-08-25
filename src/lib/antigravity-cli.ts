import { exec, spawn } from "child_process";
import fs from "fs";
import path from "path";

export interface AgyStatusInfo {
  available: boolean;
  cliPath?: string;
  version?: string;
  engineName: string;
  statusNote: string;
}

function checkFileExistsSafe(filePath: string): boolean {
  try {
    if (!filePath || filePath === "agy" || filePath === "agy.exe") return false;
    return fs.existsSync(filePath);
  } catch {
    return false;
  }
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
  ];

  for (const p of candidatePaths) {
    if (checkFileExistsSafe(p)) {
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

  if (binaryPath && checkFileExistsSafe(binaryPath)) {
    return {
      available: true,
      cliPath: binaryPath,
      engineName: "Antigravity CLI (agy)",
      statusNote: "محرك وكيل Antigravity المحلي جاهز ونشط ومكتشف بنجاح",
    };
  }

  return new Promise((resolve) => {
    exec(`"${binaryPath}" --help`, { timeout: 4000 }, (error, stdout, stderr) => {
      const combined = (stdout || "") + (stderr || "");
      if (combined.includes("Usage of agy") || combined.includes("Usage: agy") || combined.includes("agy.exe")) {
        resolve({
          available: true,
          cliPath: binaryPath,
          engineName: "Antigravity CLI (agy)",
          statusNote: "محرك وكيل Antigravity المحلي جاهز ونشط ومكتشف بنجاح",
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
  timeoutMs: number = 60000
): Promise<string> {
  const binaryPath = findAgyBinaryPath() || "agy";

  return new Promise((resolve, reject) => {
    const child = spawn(
      /*turbopackIgnore: true*/ binaryPath,
      [
        "--print",
        promptText,
        "--output-format",
        "json",
        "--effort",
        "low",
        "--disable-slash-commands",
        "--dangerously-skip-permissions",
      ],
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
export function extractJsonFromAgyResponse(rawOutput: string): unknown {
  if (!rawOutput) return null;

  let textToParse = rawOutput.trim();

  // 1. Direct JSON parse or AGY wrapper response parse
  try {
    const parsed = JSON.parse(textToParse);
    if (parsed.response && typeof parsed.response === "string") {
      textToParse = parsed.response.trim();
      try {
        return JSON.parse(textToParse);
      } catch {
        // Continue to code block parsing on inner response
      }
    } else if (parsed.reportId || parsed.faultCategories) {
      return parsed;
    }
  } catch {
    // Continue
  }

  // 2. Extract JSON code block
  const jsonMatch = textToParse.match(/```(?:json)?\s*([\s\S]*?)\s*```/);
  if (jsonMatch && jsonMatch[1]) {
    try {
      return JSON.parse(jsonMatch[1].trim());
    } catch {
      // Continue
    }
  }

  // 3. Try to locate first '{' and last '}'
  const firstBrace = textToParse.indexOf("{");
  const lastBrace = textToParse.lastIndexOf("}");
  if (firstBrace !== -1 && lastBrace !== -1 && lastBrace > firstBrace) {
    try {
      const extracted = textToParse.substring(firstBrace, lastBrace + 1);
      return JSON.parse(extracted);
    } catch {
      // Failed
    }
  }

  return null;
}
