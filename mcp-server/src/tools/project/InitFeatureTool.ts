import { z } from 'zod';
import { M42Tool } from '../../core/M42Tool.js';
import type { ExecutionContext, M42Command, ToolResult } from '../../types/index.js';

const inputSchema = z.object({
  id: z.string().describe('Feature ID (e.g., FEAT-001)'),
  name: z.string().describe('Feature name'),
  description: z.string().optional().describe('Feature description'),
});

type Input = z.infer<typeof inputSchema>;

interface InitFeatureOutput {
  featureId: string;
  featurePath: string;
  message: string;
}

export class InitFeatureTool extends M42Tool<Input, InitFeatureOutput> {
  constructor() {
    super(
      'm42_init_feature',
      'Initialize a new feature with the specified ID and name',
      inputSchema
    );
  }

  async execute(input: Input, context: ExecutionContext): Promise<ToolResult<InitFeatureOutput>> {
    try {
      const validatedInput = this.validateInput(input);
      
      this.logger.info('Initializing feature', {
        id: validatedInput.id,
        name: validatedInput.name,
      });

      const args = ['init-feature', validatedInput.id, validatedInput.name];
      
      if (validatedInput.description) {
        args.push('--description', validatedInput.description);
      }

      const command: M42Command = {
        command: context.m42Path,
        args,
        options: {
          cwd: context.workingDirectory,
        },
      };

      const result = await this.executor.execute(command, context);
      
      if (!result.success) {
        return this.createErrorResult(
          result.error || 'Failed to initialize feature'
        );
      }

      const featurePath = `${context.workingDirectory}/specs/features/${validatedInput.id}`;
      
      return this.createSuccessResult({
        featureId: validatedInput.id,
        featurePath,
        message: `Feature ${validatedInput.id} initialized successfully`,
      });
    } catch (error) {
      this.logger.error('Failed to initialize feature', {
        error: error instanceof Error ? error.message : String(error),
      });
      
      return this.createErrorResult(
        error instanceof Error ? error.message : 'Failed to initialize feature'
      );
    }
  }
}