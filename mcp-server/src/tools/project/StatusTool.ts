import { z } from 'zod';
import { M42Tool } from '../../core/M42Tool.js';
import type { ExecutionContext, M42Command, ToolResult } from '../../types/index.js';

const inputSchema = z.object({
  verbose: z.boolean().optional().default(false).describe('Show detailed status information'),
});

type Input = z.infer<typeof inputSchema>;

interface StatusOutput {
  project: {
    name: string;
    path: string;
    initialized: boolean;
  };
  currentFeature?: {
    id: string;
    name: string;
    status: string;
  };
  currentMilestone?: {
    id: string;
    name: string;
    status: string;
    progress: number;
  };
}

export class StatusTool extends M42Tool<Input, StatusOutput> {
  constructor() {
    super(
      'm42_status',
      'Get the current status of the m42-dev project, including active feature and milestone',
      inputSchema
    );
  }

  async execute(input: Input, context: ExecutionContext): Promise<ToolResult<StatusOutput>> {
    try {
      const validatedInput = this.validateInput(input);
      
      this.logger.info('Getting project status', { verbose: validatedInput.verbose });

      const command: M42Command = {
        command: context.m42Path,
        args: validatedInput.verbose ? ['status', '--verbose'] : ['status'],
        options: {
          cwd: context.workingDirectory,
        },
      };

      const result = await this.executor.execute(command, context);
      
      if (!result.success) {
        return this.createErrorResult(
          result.error || 'Failed to get project status'
        );
      }

      // Parse the output
      const sections = this.parser.parseSections(result.data!);
      const projectInfo = this.parseProjectInfo(sections);
      const featureInfo = this.parseFeatureInfo(sections);
      const milestoneInfo = this.parseMilestoneInfo(sections);

      return this.createSuccessResult({
        project: projectInfo,
        currentFeature: featureInfo,
        currentMilestone: milestoneInfo,
      });
    } catch (error) {
      this.logger.error('Failed to get status', {
        error: error instanceof Error ? error.message : String(error),
      });
      
      return this.createErrorResult(
        error instanceof Error ? error.message : 'Failed to get status'
      );
    }
  }

  private parseProjectInfo(sections: Record<string, string[]>): StatusOutput['project'] {
    const projectSection = sections['PROJECT'] || [];
    const info: Record<string, string> = {};
    
    for (const line of projectSection) {
      const match = line.match(/^([^:]+):\s*(.*)$/);
      if (match) {
        info[match[1].trim()] = match[2].trim();
      }
    }

    return {
      name: info['Name'] || 'Unknown',
      path: info['Path'] || '.',
      initialized: info['Status'] === 'Initialized',
    };
  }

  private parseFeatureInfo(sections: Record<string, string[]>): StatusOutput['currentFeature'] | undefined {
    const featureSection = sections['CURRENT FEATURE'] || [];
    if (featureSection.length === 0) return undefined;

    const info: Record<string, string> = {};
    
    for (const line of featureSection) {
      const match = line.match(/^([^:]+):\s*(.*)$/);
      if (match) {
        info[match[1].trim()] = match[2].trim();
      }
    }

    if (!info['ID']) return undefined;

    return {
      id: info['ID'],
      name: info['Name'] || 'Unknown',
      status: info['Status'] || 'Unknown',
    };
  }

  private parseMilestoneInfo(sections: Record<string, string[]>): StatusOutput['currentMilestone'] | undefined {
    const milestoneSection = sections['CURRENT MILESTONE'] || [];
    if (milestoneSection.length === 0) return undefined;

    const info: Record<string, string> = {};
    
    for (const line of milestoneSection) {
      const match = line.match(/^([^:]+):\s*(.*)$/);
      if (match) {
        info[match[1].trim()] = match[2].trim();
      }
    }

    if (!info['ID']) return undefined;

    return {
      id: info['ID'],
      name: info['Name'] || 'Unknown',
      status: info['Status'] || 'Unknown',
      progress: parseInt(info['Progress'] || '0', 10),
    };
  }
}