import type { z } from 'zod';

export interface ToolResult<T = unknown> {
  success: boolean;
  data?: T;
  error?: string;
  metadata?: Record<string, unknown>;
}

export interface M42Command {
  command: string;
  args: string[];
  options?: {
    cwd?: string;
    timeout?: number;
    env?: Record<string, string>;
  };
}

export interface ExecutionContext {
  projectRoot: string;
  workingDirectory: string;
  m42Path: string;
  cancellationToken?: AbortSignal;
}

export type ToolSchema = z.ZodObject<z.ZodRawShape>;

export interface M42Tool<TInput = unknown, TOutput = unknown> {
  name: string;
  description: string;
  inputSchema: ToolSchema;
  execute(input: TInput, context: ExecutionContext): Promise<ToolResult<TOutput>>;
}