/**
 * 📱 QR Code API - Bridge the physical and digital
 */
export declare class QRCodeAPI {
    generate(text: string, size?: number): Promise<{
        content: {
            type: string;
            text: string;
        }[];
    }>;
}
//# sourceMappingURL=qr.d.ts.map