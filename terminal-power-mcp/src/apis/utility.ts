/**
 * 🛠️ Utility APIs - Essential digital tools
 */

export class UtilityAPI {
  async generateUUID() {
    try {
      const response = await fetch('https://httpbin.org/uuid');
      const data = await response.json();
      
      if (!response.ok) {
        throw new Error('UUID service unavailable');
      }
      
      return {
        content: [
          {
            type: 'text',
            text: `🆔 **Unique ID Generated**\n\n\`${data.uuid}\`\n\n*Cryptographically secure identifier*`,
          },
        ],
      };
    } catch (error: any) {
      throw new Error(`UUID generation failed: ${error?.message || "Unknown error"}`);
    }
  }
  
  async getIP() {
    try {
      const response = await fetch('https://httpbin.org/ip');
      const data = await response.json();
      
      if (!response.ok) {
        throw new Error('IP service unavailable');
      }
      
      return {
        content: [
          {
            type: 'text',
            text: `🌐 **Your Public IP Address**\n\n\`${data.origin}\`\n\n*Your current internet identity*`,
          },
        ],
      };
    } catch (error: any) {
      throw new Error(`IP lookup failed: ${error?.message || "Unknown error"}`);
    }
  }
  
  async getCatFact() {
    try {
      const response = await fetch('https://catfact.ninja/fact');
      const data = await response.json();
      
      if (!response.ok) {
        throw new Error('Cat fact service unavailable');
      }
      
      return {
        content: [
          {
            type: 'text',
            text: `🐱 **Cat Fact of the Moment**\n\n*${data.fact}*\n\n🎯 *Internet culture distilled*`,
          },
        ],
      };
    } catch (error: any) {
      throw new Error(`Cat fact retrieval failed: ${error?.message || "Unknown error"}`);
    }
  }
}