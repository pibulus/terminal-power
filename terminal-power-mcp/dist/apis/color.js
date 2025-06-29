/**
 * 🎨 Color API - Because design matters
 */
export class ColorAPI {
    cleanHex(hex) {
        return hex.replace('#', '').toUpperCase();
    }
    async identify(hex) {
        try {
            const cleanHex = this.cleanHex(hex);
            const response = await fetch(`https://www.thecolorapi.com/id?hex=${cleanHex}`);
            const data = await response.json();
            if (!response.ok) {
                throw new Error('Color API unavailable');
            }
            return {
                content: [
                    {
                        type: 'text',
                        text: `🎨 **Color Analysis**\n\n🏷️ **Name:** ${data.name.value}\n🌈 **Hex:** ${data.hex.value}\n🔴 **RGB:** ${data.rgb.value}\n🎯 **HSL:** ${data.hsl.value}\n\n*Color data from TheColorAPI*`,
                    },
                ],
            };
        }
        catch (error) {
            throw new Error(`Color identification failed: ${error?.message || "Unknown error"}`);
        }
    }
    async generateScheme(hex, mode = 'analogic') {
        try {
            const cleanHex = this.cleanHex(hex);
            const response = await fetch(`https://www.thecolorapi.com/scheme?hex=${cleanHex}&mode=${mode}&count=5`);
            const data = await response.json();
            if (!response.ok) {
                throw new Error('Color scheme API unavailable');
            }
            const colors = data.colors.map((color) => `🎨 **${color.hex.value}** - ${color.name.value}`).join('\n');
            return {
                content: [
                    {
                        type: 'text',
                        text: `🎨 **${mode.charAt(0).toUpperCase() + mode.slice(1)} Color Scheme**\n\n${colors}\n\n*Based on #${cleanHex}*`,
                    },
                ],
            };
        }
        catch (error) {
            throw new Error(`Color scheme generation failed: ${error?.message || "Unknown error"}`);
        }
    }
}
//# sourceMappingURL=color.js.map