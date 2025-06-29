#!/usr/bin/env node

/**
 * 🚀 Terminal Power MCP Server
 * 
 * Unified cyberpunk command center - All 12 APIs in one beautiful package
 * Because scattered APIs are for normies.
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

// Import our API arsenal
import { WeatherAPI } from './apis/weather.js';
import { QRCodeAPI } from './apis/qr.js';
import { ColorAPI } from './apis/color.js';
import { QuoteAPI } from './apis/quote.js';
import { FakeDataAPI } from './apis/fake.js';
import { URLShortenerAPI } from './apis/url.js';
import { PlaceholderAPI } from './apis/placeholder.js';
import { UtilityAPI } from './apis/utility.js';
import { JokeAPI } from './apis/joke.js';

// Initialize APIs
const weather = new WeatherAPI();
const qrcode = new QRCodeAPI();
const color = new ColorAPI();
const quote = new QuoteAPI();
const fake = new FakeDataAPI();
const url = new URLShortenerAPI();
const placeholder = new PlaceholderAPI();
const utility = new UtilityAPI();
const joke = new JokeAPI();

// Create the MCP server
const server = new Server(
  {
    name: 'terminal-power',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Register all our cyberpunk tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      // Weather & Location
      {
        name: 'weather',
        description: '🌤️ Get weather anywhere in the world - because climate data is power',
        inputSchema: {
          type: 'object',
          properties: {
            location: {
              type: 'string',
              description: 'City, country, or coordinates',
            },
          },
          required: ['location'],
        },
      },
      
      // Visual & Creative
      {
        name: 'qr_code',
        description: '📱 Generate QR codes instantly - bridge the physical and digital',
        inputSchema: {
          type: 'object',
          properties: {
            text: {
              type: 'string',
              description: 'Text to encode in QR code',
            },
            size: {
              type: 'number',
              description: 'Size in pixels (default: 200)',
              default: 200,
            },
          },
          required: ['text'],
        },
      },
      
      {
        name: 'color_info',
        description: '🎨 Identify colors, generate schemes - because design matters',
        inputSchema: {
          type: 'object',
          properties: {
            hex: {
              type: 'string',
              description: 'Hex color code (with or without #)',
            },
            action: {
              type: 'string',
              enum: ['identify', 'scheme'],
              description: 'identify = name the color, scheme = generate palette',
              default: 'identify',
            },
            mode: {
              type: 'string',
              enum: ['analogic', 'monochromatic', 'triad', 'complement'],
              description: 'Color scheme mode (for scheme action)',
              default: 'analogic',
            },
          },
          required: ['hex'],
        },
      },
      
      // Utility & Productivity
      {
        name: 'shorten_url',
        description: '🔗 Shorten URLs instantly - because long URLs are ugly',
        inputSchema: {
          type: 'object',
          properties: {
            url: {
              type: 'string',
              description: 'URL to shorten',
            },
          },
          required: ['url'],
        },
      },
      
      {
        name: 'generate_uuid',
        description: '🆔 Generate unique IDs - because everything needs identity',
        inputSchema: {
          type: 'object',
          properties: {},
        },
      },
      
      {
        name: 'get_ip',
        description: '🌐 Get your public IP address - know where you stand',
        inputSchema: {
          type: 'object',
          properties: {},
        },
      },
      
      // Content & Inspiration  
      {
        name: 'quote',
        description: '💬 Get inspiring quotes - fuel for the creative soul',
        inputSchema: {
          type: 'object',
          properties: {},
        },
      },
      
      {
        name: 'joke',
        description: '😂 Get random jokes - because laughter is debugging for humans',
        inputSchema: {
          type: 'object',
          properties: {},
        },
      },
      
      {
        name: 'cat_fact',
        description: '🐱 Random cat facts - internet culture distilled',
        inputSchema: {
          type: 'object',
          properties: {},
        },
      },
      
      // Development & Testing
      {
        name: 'fake_data',
        description: '🎭 Generate realistic test data - perfect for prototyping',
        inputSchema: {
          type: 'object',
          properties: {
            type: {
              type: 'string',
              enum: ['persons', 'companies', 'addresses', 'texts'],
              description: 'Type of fake data to generate',
              default: 'persons',
            },
            count: {
              type: 'number',
              description: 'Number of records to generate',
              default: 3,
            },
          },
        },
      },
      
      {
        name: 'placeholder_image',
        description: '🖼️ Generate placeholder images - visual prototyping made easy',
        inputSchema: {
          type: 'object',
          properties: {
            width: {
              type: 'number',
              description: 'Image width in pixels',
              default: 800,
            },
            height: {
              type: 'number',
              description: 'Image height in pixels',
              default: 600,
            },
          },
        },
      },
      
      // Meta & Workflow
      {
        name: 'terminal_power_workflow',
        description: '⚡ Chain multiple Terminal Power commands - workflow automation',
        inputSchema: {
          type: 'object',
          properties: {
            commands: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  tool: { type: 'string' },
                  params: { type: 'object' },
                },
              },
              description: 'Array of commands to execute in sequence',
            },
          },
          required: ['commands'],
        },
      },
    ],
  };
});

// Handle tool calls with cyberpunk flair
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  
  try {
    switch (name) {
      case 'weather':
        return await weather.getWeather((args as any)?.location);
        
      case 'qr_code':
        return await qrcode.generate((args as any)?.text, (args as any)?.size);
        
      case 'color_info':
        if ((args as any)?.action === 'scheme') {
          return await color.generateScheme((args as any)?.hex, (args as any)?.mode);
        } else {
          return await color.identify((args as any)?.hex);
        }
        
      case 'shorten_url':
        return await url.shorten((args as any)?.url);
        
      case 'generate_uuid':
        return await utility.generateUUID();
        
      case 'get_ip':
        return await utility.getIP();
        
      case 'quote':
        return await quote.getRandom();
        
      case 'joke':
        return await joke.getRandom();
        
      case 'cat_fact':
        return await utility.getCatFact();
        
      case 'fake_data':
        return await fake.generate((args as any)?.type || 'persons', (args as any)?.count || 3);
        
      case 'placeholder_image':
        return await placeholder.generate((args as any)?.width || 800, (args as any)?.height || 600);
        
      case 'terminal_power_workflow':
        return await executeWorkflow((args as any)?.commands);
        
      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error: any) {
    return {
      content: [
        {
          type: 'text',
          text: `❌ Error in ${name}: ${error?.message || 'Unknown error'}`,
        },
      ],
    };
  }
});

// Workflow execution - chain commands like a boss
async function executeWorkflow(commands: any[]) {
  const results = [];
  
  for (const cmd of commands) {
    const result = await server.request(
      { method: 'tools/call', params: { name: cmd.tool, arguments: cmd.params } },
      CallToolRequestSchema
    );
    results.push(result);
  }
  
  return {
    content: [
      {
        type: 'text',
        text: `⚡ Workflow completed with ${results.length} steps`,
      },
    ],
  };
}

// Start the cyberpunk server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('🚀 Terminal Power MCP server activated - Ready to command the digital realm');
}

main().catch((error) => {
  console.error('💥 Server crashed:', error);
  process.exit(1);
});