const serverless = require('serverless-http');
const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

// Simple mock playlist generator
function getMockPlaylists(mood = 'upbeat', language = 'English') {
    const playlists = [
        {
            playlistId: "PL123abc789",
            title: `${mood.charAt(0).toUpperCase() + mood.slice(1)} ${language} Music Mix`,
            thumbnailUrl: "https://picsum.photos/300/300?random=1"
        },
        {
            playlistId: "PL456def012", 
            title: `Dynamic ${language} Rock Collection`,
            thumbnailUrl: "https://picsum.photos/300/300?random=2"
        },
        {
            playlistId: "PL789ghi345",
            title: `Best ${language} Pop Hits`,
            thumbnailUrl: "https://picsum.photos/300/300?random=3"
        },
        {
            playlistId: "PL012jkl678",
            title: `Energetic ${language} Hip Hop`,
            thumbnailUrl: "https://picsum.photos/300/300?random=4"
        }
    ];
    return playlists;
}

// Handle ALL requests - GET, POST, OPTIONS, etc.
app.use('*', (req, res) => {
    console.log('Request received:', req.method, req.path, req.query);
    
    // Set CORS headers for all responses
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    
    // Handle OPTIONS preflight requests
    if (req.method === 'OPTIONS') {
        return res.status(200).send();
    }
    
    // For any request that could be asking for playlists, return mock data
    const { mood = 'upbeat', language = 'English' } = req.query;
    const mockPlaylists = getMockPlaylists(mood, language);
    
    return res.status(200).json(mockPlaylists);
});

module.exports.handler = serverless(app);