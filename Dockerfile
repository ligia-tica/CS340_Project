# Use Node.js LTS image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application code
COPY . .

# Expose the port the app runs on
EXPOSE 11000

# Start the application
CMD ["node", "app.js"]
