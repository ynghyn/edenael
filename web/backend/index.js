const serverless = require('serverless-http');
const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();

app.use(cors());
app.use(express.json());

// YouTube API setup using direct HTTP requests
const YOUTUBE_API_KEY = 'AIzaSyCIceLqnP_9d1wrl8eXq73CJLpLBVfC6b8';
const YOUTUBE_API_BASE_URL = 'https://www.googleapis.com/youtube/v3';

// Search YouTube playlists based on mood and genre
async function searchYouTubePlaylists(mood = '경배', genre = 'CCM') {
    try {
        console.log(`Searching for ${mood} ${genre} music playlists`);
        
        // Create search query for Korean Christian music
        let searchQuery;
        if (genre === 'CCM') {
            // Search for Korean Christian Contemporary Music
            const moodMapping = {
                '경배': '한국 CCM 경배 찬양',
                '묵상': '한국 CCM 묵상 기도',
                '찬양': '한국 CCM 찬양 워십'
            };
            const koreanQuery = moodMapping[mood] || '한국 CCM 찬양';
            searchQuery = `${koreanQuery} 플레이리스트`;
        } else {
            searchQuery = `${mood} ${genre} music playlist`;
        }
        
        const url = `${YOUTUBE_API_BASE_URL}/search`;
        
        const params = {
            part: 'snippet',
            type: 'playlist',
            q: searchQuery,
            maxResults: 8,
            regionCode: 'KR',
            key: YOUTUBE_API_KEY
        };
        
        const response = await axios.get(url, { params });
        
        if (!response.data.items || response.data.items.length === 0) {
            console.log('No playlists found, returning mock data');
            return getMockPlaylists(mood, genre);
        }
        
        const playlists = response.data.items.map(item => ({
            playlistId: item.id.playlistId,
            title: item.snippet.title,
            thumbnailUrl: item.snippet.thumbnails?.default?.url || item.snippet.thumbnails?.medium?.url || 'https://picsum.photos/300/300?random=1'
        }));
        
        console.log(`Found ${playlists.length} playlists`);
        return playlists;
        
    } catch (error) {
        console.error('Error searching YouTube playlists:', error.message);
        console.log('Falling back to mock data');
        return getMockPlaylists(mood, genre);
    }
}

// Fallback mock playlist generator for Korean Christian music
function getMockPlaylists(mood = '경배', genre = 'CCM') {
    const koreanCcmPlaylists = [
        {
            playlistId: "PL123abc789",
            title: `한국 CCM ${mood} 찬양 모음`,
            thumbnailUrl: "https://picsum.photos/300/300?random=1"
        },
        {
            playlistId: "PL456def012", 
            title: `한국 워십 베스트 플레이리스트`,
            thumbnailUrl: "https://picsum.photos/300/300?random=2"
        },
        {
            playlistId: "PL789ghi345",
            title: `CCM 한국 찬양팀 모음집`,
            thumbnailUrl: "https://picsum.photos/300/300?random=3"
        },
        {
            playlistId: "PL012jkl678",
            title: `${mood} 한국 기독교 음악`,
            thumbnailUrl: "https://picsum.photos/300/300?random=4"
        },
        {
            playlistId: "PL234bcd890",
            title: `마커스 워십 한국 찬양`,
            thumbnailUrl: "https://picsum.photos/300/300?random=5"
        },
        {
            playlistId: "PL567efg123",
            title: `어노인팅 CCM 모음`,
            thumbnailUrl: "https://picsum.photos/300/300?random=6"
        }
    ];
    return koreanCcmPlaylists;
}

// Handle specific routes and catch-all
const handlePlaylistRequest = async (req, res) => {
    console.log('Request received:', req.method, req.path, req.query);
    
    // Set CORS headers for all responses
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    
    // Handle OPTIONS preflight requests
    if (req.method === 'OPTIONS') {
        return res.status(200).send();
    }
    
    try {
        // Get playlists from YouTube API
        const { mood = '경배', genre = 'CCM' } = req.query;
        const playlists = await searchYouTubePlaylists(mood, genre);
        
        return res.status(200).json(playlists);
    } catch (error) {
        console.error('Error in handlePlaylistRequest:', error);
        // Return mock data as fallback
        const { mood = '경배', genre = 'CCM' } = req.query;
        const mockPlaylists = getMockPlaylists(mood, genre);
        return res.status(200).json(mockPlaylists);
    }
};

// Handle all possible routes
app.get('/', handlePlaylistRequest);
app.get('/api/playlists', handlePlaylistRequest);
app.get('/playlists', handlePlaylistRequest);
app.get('/health', (req, res) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Catch-all for any other route
app.use((req, res) => {
    handlePlaylistRequest(req, res);
});

module.exports.handler = serverless(app);