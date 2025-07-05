import type { M42Tool } from './types/index.js';
import { createLogger, Logger } from './core/Logger.js';

export class ToolRegistry {
  private tools: Map<string, M42Tool>;
  private logger: Logger;

  constructor() {
    this.tools = new Map();
    this.logger = createLogger('ToolRegistry');
  }

  register(tool: M42Tool): void {
    if (this.tools.has(tool.name)) {
      this.logger.warn(`Tool ${tool.name} is already registered, overwriting`);
    }
    
    this.tools.set(tool.name, tool);
    this.logger.debug(`Registered tool: ${tool.name}`);
  }

  getTool(name: string): M42Tool | undefined {
    return this.tools.get(name);
  }

  getAllTools(): M42Tool[] {
    return Array.from(this.tools.values());
  }

  getToolNames(): string[] {
    return Array.from(this.tools.keys());
  }

  clear(): void {
    this.tools.clear();
  }
}