import type { z } from 'zod';
import type { ExecutionContext, M42Tool as IM42Tool, ToolResult, ToolSchema } from '../types/index.js';
import { CommandExecutor } from './CommandExecutor.js';
import { OutputParser } from './OutputParser.js';
import { createLogger, Logger } from './Logger.js';

export abstract class M42Tool<TInput = unknown, TOutput = unknown> implements IM42Tool<TInput, TOutput> {
  protected readonly executor: CommandExecutor;
  protected readonly parser: OutputParser;
  protected readonly logger: Logger;

  constructor(
    public readonly name: string,
    public readonly description: string,
    public readonly inputSchema: ToolSchema
  ) {
    this.executor = new CommandExecutor();
    this.parser = new OutputParser();
    this.logger = createLogger(`tool:${name}`);
  }

  abstract execute(input: TInput, context: ExecutionContext): Promise<ToolResult<TOutput>>;

  protected validateInput(input: unknown): TInput {
    const result = this.inputSchema.safeParse(input);
    
    if (!result.success) {
      throw new Error(`Invalid input: ${result.error.message}`);
    }
    
    return result.data as TInput;
  }

  protected buildM42Command(args: string[]): string[] {
    return [args.join(' ')];
  }

  protected createSuccessResult(data: TOutput, metadata?: Record<string, unknown>): ToolResult<TOutput> {
    return {
      success: true,
      data,
      metadata,
    };
  }

  protected createErrorResult(error: string, metadata?: Record<string, unknown>): ToolResult<TOutput> {
    return {
      success: false,
      error,
      metadata,
    };
  }
}