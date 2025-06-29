/**
 * 🌤️ Weather API - Because climate data is power
 */
export declare class WeatherAPI {
    private getCoordinates;
    private getWeatherIcon;
    getWeather(location: string): Promise<{
        content: {
            type: string;
            text: string;
        }[];
    }>;
}
//# sourceMappingURL=weather.d.ts.map