import { z } from 'zod';
import { M42Tool } from '../../core/M42Tool.js';
import type { ExecutionContext, M42Command, ToolResult } from '../../types/index.js';

const inputSchema = z.object({
  status: z.enum(['all', 'active', 'completed']).optional().default('all')
    .describe('Filter features by status'),
});

type Input = z.infer<typeof inputSchema>;

interface Feature {
  id: string;
  name: string;
  status: string;
  createdAt: string;
  milestones?: number;
}

interface ListFeaturesOutput {
  features: Feature[];
  total: number;
}

export class ListFeaturesTool extends M42Tool<Input, ListFeaturesOutput> {
  constructor() {
    super(
      'm42_list_features',
      'List all features in the project with their status',
      inputSchema
    );
  }

  async execute(input: Input, context: ExecutionContext): Promise<ToolResult<ListFeaturesOutput>> {
    try {
      const validatedInput = this.validateInput(input);
      
      this.logger.info('Listing features', { status: validatedInput.status });

      const args = ['list-features'];
      
      if (validatedInput.status !== 'all') {
        args.push('--status', validatedInput.status);
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
          result.error || 'Failed to list features'
        );
      }

      // Parse the features from output
      const features = this.parseFeaturesOutput(result.data!.stdout);
      
      return this.createSuccessResult({
        features,
        total: features.length,
      });
    } catch (error) {
      this.logger.error('Failed to list features', {
        error: error instanceof Error ? error.message : String(error),
      });
      
      return this.createErrorResult(
        error instanceof Error ? error.message : 'Failed to list features'
      );
    }
  }

  private parseFeaturesOutput(output: string): Feature[] {
    const features: Feature[] = [];
    const lines = output.split('\n').filter(line => line.trim());
    
    // Skip header lines
    let inFeaturesList = false;
    
    for (const line of lines) {
      if (line.includes('Features:') || line.includes('FEATURES')) {
        inFeaturesList = true;
        continue;
      }
      
      if (!inFeaturesList) continue;
      
      // Parse feature line format: "ID | Name | Status | Created"
      const parts = line.split('|').map(p => p.trim());
      
      if (parts.length >= 3) {
        features.push({
          id: parts[0],
          name: parts[1],
          status: parts[2],
          createdAt: parts[3] || 'Unknown',
          milestones: parts[4] ? parseInt(parts[4], 10) : undefined,
        });
      }
    }
    
    return features;
  }
}