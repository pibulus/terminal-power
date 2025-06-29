/**
 * 💬 Quote API - Fuel for the creative soul
 */
export class QuoteAPI {
    async getRandom() {
        try {
            const response = await fetch('https://dummyjson.com/quotes/random');
            const data = await response.json();
            if (!response.ok) {
                throw new Error('Quote service unavailable');
            }
            return {
                content: [
                    {
                        type: 'text',
                        text: `💬 **Daily Inspiration**\n\n*"${data.quote}"*\n\n— **${data.author}**\n\n✨ *Let this fuel your creativity*`,
                    },
                ],
            };
        }
        catch (error) {
            throw new Error(`Quote retrieval failed: ${error?.message || "Unknown error"}`);
        }
    }
}
//# sourceMappingURL=quote.js.map