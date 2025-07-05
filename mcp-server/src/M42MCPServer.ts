import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { ServerTransport } from '@modelcontextprotocol/sdk/server/types.js';
import type { ExecutionContext } from './types/index.js';
import { createLogger, Logger } from './core/Logger.js';
import { ToolRegistry } from './ToolRegistry.js';
import { registerAllTools } from './tools/index.js';
import path from 'path';

export class M42MCPServer {
  private server: Server;
  private registry: ToolRegistry;
  private logger: Logger;
  private context: ExecutionContext;

  constructor() {
    this.logger = createLogger('M42MCPServer');
    this.server = new Server(
      {
        name: 'm42-dev-mcp',
        version: '0.1.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );
    
    this.registry = new ToolRegistry();
    this.context = this.createExecutionContext();
    
    this.setupHandlers();
    this.registerTools();
  }

  async connect(transport: ServerTransport): Promise<void> {
    await this.server.connect(transport);
  }

  async close(): Promise<void> {
    await this.server.close();
  }

  private createExecutionContext(): ExecutionContext {
    const projectRoot = process.env.M42_PROJECT_ROOT || process.cwd();
    const m42Path = process.env.M42_PATH || path.join(projectRoot, 'm42-dev.sh');
    
    return {
      projectRoot,
      workingDirectory: projectRoot,
      m42Path,
    };
  }

  private setupHandlers(): void {
    // Handle tool listing
    this.server.setRequestHandler('tools/list', async () => {
      const tools = this.registry.getAllTools();
      
      return {
        tools: tools.map(tool => ({
          name: tool.name,
          description: tool.description,
          inputSchema: tool.inputSchema.shape,
        })),
      };
    });

    // Handle tool execution
    this.server.setRequestHandler('tools/call', async (request) => {
      try {
        const { name, arguments: args } = request as {
          name: string;
          arguments?: unknown;
        };

        this.logger.info('Executing tool', { tool: name, args });

        const tool = this.registry.getTool(name);
        if (!tool) {
          throw new Error(`Tool not found: ${name}`);
        }

        const result = await tool.execute(args || {}, this.context);
        
        this.logger.info('Tool execution completed', { 
          tool: name, 
          success: result.success 
        });

        if (result.success) {
          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify(result.data, null, 2),
              },
            ],
          };
        } else {
          return {
            content: [
              {
                type: 'text',
                text: `Error: ${result.error || 'Unknown error'}`,
              },
            ],
            isError: true,
          };
        }
      } catch (error) {
        this.logger.error('Tool execution failed', {
          error: error instanceof Error ? error.message : String(error),
        });
        
        return {
          content: [
            {
              type: 'text',
              text: `Error: ${error instanceof Error ? error.message : String(error)}`,
            },
          ],
          isError: true,
        };
      }
    });
  }

  private registerTools(): void {
    registerAllTools(this.registry);
    
    const toolCount = this.registry.getAllTools().length;
    this.logger.info(`Registered ${toolCount} tools`);
  }
}