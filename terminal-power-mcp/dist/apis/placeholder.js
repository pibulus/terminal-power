/**
 * 🖼️ Placeholder Image API - Visual prototyping made easy
 */
export class PlaceholderAPI {
    async generate(width = 800, height = 600) {
        try {
            const imageUrl = `https://dummyimage.com/${width}x${height}`;
            // Verify the service is available
            const response = await fetch(imageUrl, { method: 'HEAD' });
            if (!response.ok) {
                throw new Error('Placeholder image service unavailable');
            }
            return {
                content: [
                    {
                        type: 'text',
                        text: `🖼️ **Placeholder Image Generated**\n\n📏 **Dimensions:** ${width} × ${height}px\n🔗 **URL:** ${imageUrl}\n\n*Perfect for mockups and prototypes*`,
                    },
                ],
            };
        }
        catch (error) {
            throw new Error(`Placeholder generation failed: ${error?.message || "Unknown error"}`);
        }
    }
}
//# sourceMappingURL=placeholder.js.map