import { ToolRegistry } from '../ToolRegistry.js';
import { M42Tool } from '../core/M42Tool.js';
import { z } from 'zod';
import type { ExecutionContext, ToolResult } from '../types/index.js';

class MockTool extends M42Tool<unknown, unknown> {
  constructor(name: string) {
    super(
      name,
      `Mock tool ${name}`,
      z.object({})
    );
  }

  async execute(_input: unknown, _context: ExecutionContext): Promise<ToolResult<unknown>> {
    return {
      success: true,
      data: { message: 'Mock execution' },
    };
  }
}

describe('ToolRegistry', () => {
  let registry: ToolRegistry;

  beforeEach(() => {
    registry = new ToolRegistry();
  });

  test('should register and retrieve a tool', () => {
    const tool = new MockTool('test-tool');
    registry.register(tool);
    
    const retrieved = registry.getTool('test-tool');
    expect(retrieved).toBe(tool);
  });

  test('should return undefined for non-existent tool', () => {
    const retrieved = registry.getTool('non-existent');
    expect(retrieved).toBeUndefined();
  });

  test('should return all registered tools', () => {
    const tool1 = new MockTool('tool1');
    const tool2 = new MockTool('tool2');
    
    registry.register(tool1);
    registry.register(tool2);
    
    const allTools = registry.getAllTools();
    expect(allTools).toHaveLength(2);
    expect(allTools).toContain(tool1);
    expect(allTools).toContain(tool2);
  });

  test('should return tool names', () => {
    const tool1 = new MockTool('tool1');
    const tool2 = new MockTool('tool2');
    
    registry.register(tool1);
    registry.register(tool2);
    
    const names = registry.getToolNames();
    expect(names).toEqual(['tool1', 'tool2']);
  });

  test('should clear all tools', () => {
    const tool = new MockTool('test-tool');
    registry.register(tool);
    
    registry.clear();
    
    expect(registry.getAllTools()).toHaveLength(0);
    expect(registry.getTool('test-tool')).toBeUndefined();
  });

  test('should overwrite existing tool with same name', () => {
    const tool1 = new MockTool('test-tool');
    const tool2 = new MockTool('test-tool');
    
    registry.register(tool1);
    registry.register(tool2);
    
    const retrieved = registry.getTool('test-tool');
    expect(retrieved).toBe(tool2);
    expect(registry.getAllTools()).toHaveLength(1);
  });
});