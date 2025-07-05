import { spawn } from 'child_process';
import type { M42Command, ExecutionContext, ToolResult } from '../types/index.js';

export interface CommandOutput {
  stdout: string;
  stderr: string;
  exitCode: number;
}

export class CommandExecutor {
  private readonly defaultTimeout = 600000; // 10 minutes

  async execute(
    command: M42Command,
    context: ExecutionContext
  ): Promise<ToolResult<CommandOutput>> {
    try {
      const output = await this.runCommand(command, context);
      
      return {
        success: output.exitCode === 0,
        data: output,
        error: output.exitCode !== 0 ? output.stderr : undefined,
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error occurred',
      };
    }
  }

  private runCommand(
    command: M42Command,
    context: ExecutionContext
  ): Promise<CommandOutput> {
    return new Promise((resolve, reject) => {
      const timeout = command.options?.timeout ?? this.defaultTimeout;
      const cwd = command.options?.cwd ?? context.workingDirectory;
      
      const env = {
        ...process.env,
        ...command.options?.env,
      };

      const proc = spawn(command.command, command.args, {
        cwd,
        env,
        shell: true,
      });

      let stdout = '';
      let stderr = '';
      let timeoutHandle: NodeJS.Timeout | null = null;

      // Set timeout
      if (timeout > 0) {
        timeoutHandle = setTimeout(() => {
          proc.kill('SIGTERM');
          reject(new Error(`Command timed out after ${timeout}ms`));
        }, timeout);
      }

      // Handle cancellation
      if (context.cancellationToken) {
        context.cancellationToken.addEventListener('abort', () => {
          proc.kill('SIGTERM');
          reject(new Error('Command cancelled'));
        });
      }

      proc.stdout.on('data', (data: Buffer) => {
        stdout += data.toString();
      });

      proc.stderr.on('data', (data: Buffer) => {
        stderr += data.toString();
      });

      proc.on('error', (error: Error) => {
        if (timeoutHandle) clearTimeout(timeoutHandle);
        reject(error);
      });

      proc.on('close', (code: number | null) => {
        if (timeoutHandle) clearTimeout(timeoutHandle);
        
        resolve({
          stdout: stdout.trim(),
          stderr: stderr.trim(),
          exitCode: code ?? -1,
        });
      });
    });
  }
}