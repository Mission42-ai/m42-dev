import { z } from 'zod';
import { M42Tool } from '../../core/M42Tool.js';
import type { ExecutionContext, M42Command, ToolResult } from '../../types/index.js';

const inputSchema = z.object({
  name: z.string().describe('Project name'),
  template: z.string().optional().default('default').describe('Project template to use'),
});

type Input = z.infer<typeof inputSchema>;

interface InitProjectOutput {
  projectPath: string;
  message: string;
}

export class InitProjectTool extends M42Tool<Input, InitProjectOutput> {
  constructor() {
    super(
      'm42_init_project',
      'Initialize a new m42-dev project with the specified name and template',
      inputSchema
    );
  }

  async execute(input: Input, context: ExecutionContext): Promise<ToolResult<InitProjectOutput>> {
    try {
      const validatedInput = this.validateInput(input);
      
      this.logger.info('Initializing project', {
        name: validatedInput.name,
        template: validatedInput.template,
      });

      const command: M42Command = {
        command: context.m42Path,
        args: ['init', validatedInput.name, '--template', validatedInput.template],
        options: {
          cwd: context.workingDirectory,
        },
      };

      const result = await this.executor.execute(command, context);
      
      if (!result.success) {
        return this.createErrorResult(
          result.error || 'Failed to initialize project'
        );
      }

      const projectPath = `${context.workingDirectory}/${validatedInput.name}`;
      
      return this.createSuccessResult({
        projectPath,
        message: `Project ${validatedInput.name} initialized successfully`,
      });
    } catch (error) {
      this.logger.error('Failed to initialize project', {
        error: error instanceof Error ? error.message : String(error),
      });
      
      return this.createErrorResult(
        error instanceof Error ? error.message : 'Failed to initialize project'
      );
    }
  }
}