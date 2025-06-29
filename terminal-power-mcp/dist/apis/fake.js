/**
 * 🎭 Fake Data API - Perfect for prototyping
 */
export class FakeDataAPI {
    async generate(type = 'persons', count = 3) {
        try {
            const response = await fetch(`https://fakerapi.it/api/v1/${type}?_quantity=${count}`);
            const data = await response.json();
            if (!response.ok || data.status !== 'OK') {
                throw new Error('Fake data service unavailable');
            }
            const preview = data.data.slice(0, 2).map((item, index) => {
                if (type === 'persons') {
                    return `👤 **${item.firstname} ${item.lastname}**\n📧 ${item.email}\n📱 ${item.phone}`;
                }
                else if (type === 'companies') {
                    return `🏢 **${item.name}**\n🌐 ${item.website}\n📧 ${item.email}`;
                }
                else {
                    return `📝 **Item ${index + 1}:** ${JSON.stringify(item, null, 2).slice(0, 100)}...`;
                }
            }).join('\n\n');
            return {
                content: [
                    {
                        type: 'text',
                        text: `🎭 **Generated ${count} ${type}**\n\n${preview}\n\n${count > 2 ? `...and ${count - 2} more items` : ''}\n\n*Perfect for testing and prototyping*`,
                    },
                ],
            };
        }
        catch (error) {
            throw new Error(`Fake data generation failed: ${error?.message || "Unknown error"}`);
        }
    }
}
//# sourceMappingURL=fake.js.map