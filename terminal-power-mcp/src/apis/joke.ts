/**
 * 😂 Joke API - Laughter is debugging for humans
 */

export class JokeAPI {
  async getRandom() {
    try {
      const response = await fetch('https://official-joke-api.appspot.com/random_joke');
      const data = await response.json();
      
      if (!response.ok) {
        throw new Error('Joke service unavailable');
      }
      
      return {
        content: [
          {
            type: 'text',
            text: `😂 **Random Joke**\n\n**${data.setup}**\n\n*${data.punchline}*\n\n🎭 *Type: ${data.type}*`,
          },
        ],
      };
    } catch (error: any) {
      throw new Error(`Joke retrieval failed: ${error?.message || "Unknown error"}`);
    }
  }
}