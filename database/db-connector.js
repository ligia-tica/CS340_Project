// Citation for the following code:
// Date: 11/4/2025 (various additional dates)
// Base code used from Exploration - Web Application Technology and Exploration Implementing CUD Operations in your app
// URL: https://canvas.oregonstate.edu/courses/2017561/pages/exploration-web-application-technology-2?module_item_id=25645131


// Get an instance of mysql we can use in the app
let mysql = require('mysql2')

// Create a 'connection pool' using the provided credentials
// Uses environment variables for Docker deployment, with fallbacks for local development
const pool = mysql.createPool({
    waitForConnections: true,
    connectionLimit   : 10,
    host              : process.env.DB_HOST || 'classmysql.engr.oregonstate.edu',
    user              : process.env.DB_USER || 'cs340_',
    password          : process.env.DB_PASSWORD || '',
    database          : process.env.DB_NAME || 'cs340_',
    port              : process.env.DB_PORT || 3306
}).promise(); // This makes it so we can use async / await rather than callbacks

// Export it for use in our application
module.exports = pool;
