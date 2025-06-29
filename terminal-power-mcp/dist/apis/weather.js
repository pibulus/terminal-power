/**
 * 🌤️ Weather API - Because climate data is power
 */
export class WeatherAPI {
    async getCoordinates(location) {
        const response = await fetch(`https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(location)}&format=json&limit=1`);
        const data = await response.json();
        if (!data || data.length === 0) {
            throw new Error(`Location '${location}' not found`);
        }
        return {
            lat: parseFloat(data[0].lat),
            lon: parseFloat(data[0].lon),
            name: data[0].display_name,
        };
    }
    getWeatherIcon(code) {
        // WMO Weather interpretation codes
        const weatherIcons = {
            0: '☀️', // Clear sky
            1: '🌤️', // Mainly clear
            2: '⛅', // Partly cloudy
            3: '☁️', // Overcast
            45: '🌫️', // Fog
            48: '🌫️', // Depositing rime fog
            51: '🌦️', // Light drizzle
            53: '🌦️', // Moderate drizzle
            55: '🌦️', // Dense drizzle
            61: '🌧️', // Slight rain
            63: '🌧️', // Moderate rain
            65: '🌧️', // Heavy rain
            71: '🌨️', // Slight snow fall
            73: '🌨️', // Moderate snow fall
            75: '🌨️', // Heavy snow fall
            80: '🌦️', // Slight rain showers
            81: '🌦️', // Moderate rain showers
            82: '🌦️', // Violent rain showers
            95: '⛈️', // Thunderstorm
            96: '⛈️', // Thunderstorm with slight hail
            99: '⛈️', // Thunderstorm with heavy hail
        };
        return weatherIcons[code] || '🌤️';
    }
    async getWeather(location) {
        try {
            // Get coordinates for location
            const coords = await this.getCoordinates(location);
            // Get weather data from Open-Meteo
            const weatherResponse = await fetch(`https://api.open-meteo.com/v1/forecast?latitude=${coords.lat}&longitude=${coords.lon}&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&timezone=auto`);
            const weatherData = await weatherResponse.json();
            const current = weatherData.current;
            const icon = this.getWeatherIcon(current.weather_code);
            const locationName = coords.name.split(',').slice(0, 2).join(', ');
            return {
                content: [
                    {
                        type: 'text',
                        text: `🌤️ **Weather for ${locationName}**\n\n${icon} **${Math.round(current.temperature_2m)}°C**\n💧 Humidity: ${current.relative_humidity_2m}%\n💨 Wind: ${current.wind_speed_10m} km/h\n\n*Data from Open-Meteo API*`,
                    },
                ],
            };
        }
        catch (error) {
            throw new Error(`Weather lookup failed: ${error?.message || 'Unknown error'}`);
        }
    }
}
//# sourceMappingURL=weather.js.map