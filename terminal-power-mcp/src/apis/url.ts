/**
 * 🔗 URL Shortener API - Because long URLs are ugly
 */

export class URLShortenerAPI {
  async shorten(url: string) {
    try {
      // Validate URL format
      try {
        new URL(url);
      } catch {
        throw new Error('Invalid URL format');
      }
      
      const response = await fetch(
        `https://is.gd/create.php?format=simple&url=${encodeURIComponent(url)}`
      );
      
      if (!response.ok) {
        throw new Error('URL shortening service unavailable');
      }
      
      const shortUrl = await response.text();
      
      if (shortUrl.includes('Error')) {
        throw new Error('URL could not be shortened');
      }
      
      return {
        content: [
          {
            type: 'text',
            text: `🔗 **URL Shortened**\n\n📎 **Original:** ${url}\n⚡ **Short:** ${shortUrl}\n\n*Share the short link anywhere*`,
          },
        ],
      };
    } catch (error: any) {
      throw new Error(`URL shortening failed: ${error?.message || "Unknown error"}`);
    }
  }
}