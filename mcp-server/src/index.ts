import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { createLogger } from './core/Logger.js';
import { M42MCPServer } from './M42MCPServer.js';

const logger = createLogger('main');

async function main(): Promise<void> {
  try {
    logger.info('Starting M42-Dev MCP Server');

    const server = new M42MCPServer();
    const transport = new StdioServerTransport();

    await server.connect(transport);
    
    logger.info('M42-Dev MCP Server started successfully');

    // Handle graceful shutdown
    process.on('SIGINT', async () => {
      logger.info('Received SIGINT, shutting down gracefully');
      await server.close();
      process.exit(0);
    });

    process.on('SIGTERM', async () => {
      logger.info('Received SIGTERM, shutting down gracefully');
      await server.close();
      process.exit(0);
    });

  } catch (error) {
    logger.error('Failed to start server', { 
      error: error instanceof Error ? error.message : String(error) 
    });
    process.exit(1);
  }
}

// Run the server
void main();