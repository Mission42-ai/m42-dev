import type { CommandOutput } from './CommandExecutor.js';

export class OutputParser {
  parseJson<T>(output: CommandOutput): T | null {
    try {
      const content = output.stdout || output.stderr;
      return JSON.parse(content) as T;
    } catch {
      return null;
    }
  }

  parseKeyValue(output: CommandOutput): Record<string, string> {
    const lines = (output.stdout || '').split('\n').filter(line => line.trim());
    const result: Record<string, string> = {};

    for (const line of lines) {
      const match = line.match(/^([^:]+):\s*(.*)$/);
      if (match) {
        const [, key, value] = match;
        result[key.trim()] = value.trim();
      }
    }

    return result;
  }

  parseList(output: CommandOutput): string[] {
    return (output.stdout || '')
      .split('\n')
      .map(line => line.trim())
      .filter(line => line.length > 0);
  }

  parseSections(output: CommandOutput): Record<string, string[]> {
    const lines = (output.stdout || '').split('\n');
    const sections: Record<string, string[]> = {};
    let currentSection = '';

    for (const line of lines) {
      if (line.startsWith('=== ') && line.endsWith(' ===')) {
        currentSection = line.slice(4, -4).trim();
        sections[currentSection] = [];
      } else if (currentSection && line.trim()) {
        sections[currentSection].push(line);
      }
    }

    return sections;
  }

  extractSuccess(output: CommandOutput): boolean {
    const stdout = output.stdout.toLowerCase();
    const stderr = output.stderr.toLowerCase();
    
    // Check for explicit success indicators
    if (stdout.includes('success') || stdout.includes('completed')) {
      return true;
    }
    
    // Check for error indicators
    if (
      stderr.includes('error') || 
      stderr.includes('failed') ||
      stdout.includes('error') ||
      stdout.includes('failed')
    ) {
      return false;
    }
    
    // Default to exit code
    return output.exitCode === 0;
  }

  sanitizeForJson(text: string): string {
    return text
      .replace(/\\/g, '\\\\')
      .replace(/"/g, '\\"')
      .replace(/\n/g, '\\n')
      .replace(/\r/g, '\\r')
      .replace(/\t/g, '\\t');
  }
}