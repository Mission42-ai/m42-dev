import type { ToolRegistry } from '../ToolRegistry.js';
import { InitProjectTool } from './project/InitProjectTool.js';
import { StatusTool } from './project/StatusTool.js';
import { InitFeatureTool } from './project/InitFeatureTool.js';
import { ListFeaturesTool } from './project/ListFeaturesTool.js';

export function registerAllTools(registry: ToolRegistry): void {
  // Project Management Tools
  registry.register(new InitProjectTool());
  registry.register(new StatusTool());
  registry.register(new InitFeatureTool());
  registry.register(new ListFeaturesTool());
  
  // TODO: Add more tools as we implement them
  // - StartMilestoneTool
  // - ListMilestonesTool
  // - ResetTool
  // - AnalyzeProjectTool
  // - ImplementTaskTool
  // - RunTestsTool
  // - GitStatusTool
  // - GitCommitTool
  // etc.
}