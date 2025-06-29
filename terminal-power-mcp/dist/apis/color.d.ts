/**
 * 🎨 Color API - Because design matters
 */
export declare class ColorAPI {
    private cleanHex;
    identify(hex: string): Promise<{
        content: {
            type: string;
            text: string;
        }[];
    }>;
    generateScheme(hex: string, mode?: string): Promise<{
        content: {
            type: string;
            text: string;
        }[];
    }>;
}
//# sourceMappingURL=color.d.ts.map