# Step 1: Use Node.js for building the app
FROM node:18-alpine AS build

WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy all source code
COPY . .

# Build the Vite app
RUN npm run build

# Step 2: Use a lightweight server to serve the build (nginx)
FROM nginx:alpine

# Copy build output from build stage to nginx HTML folder
COPY --from=build /app/dist /usr/share/nginx/html

# Expose Vite default port
EXPOSE 5173

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

