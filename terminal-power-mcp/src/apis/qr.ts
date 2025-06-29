/**
 * 📱 QR Code API - Bridge the physical and digital
 */

export class QRCodeAPI {
  async generate(text: string, size: number = 200) {
    try {
      const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=${size}x${size}&data=${encodeURIComponent(text)}`;
      
      // Verify the API is responsive
      const response = await fetch(qrUrl, { method: 'HEAD' });
      
      if (!response.ok) {
        throw new Error('QR service unavailable');
      }
      
      return {
        content: [
          {
            type: 'text',
            text: `📱 **QR Code Generated**\n\n🎯 **Content:** ${text}\n📏 **Size:** ${size}x${size}px\n🔗 **URL:** ${qrUrl}\n\n*Scan with any QR code reader*`,
          },
        ],
      };
    } catch (error: any) {
      throw new Error(`QR generation failed: ${error?.message || "Unknown error"}`);
    }
  }
}