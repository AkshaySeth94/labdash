# Use the official Node.js 22 LTS slim image as a parent image
FROM node:22-slim

# Set the working directory in the container
WORKDIR /workspace

# Copy package.json files for the root and both workspaces.
# This allows us to leverage Docker's layer caching to avoid re-installing
# dependencies if they haven't changed.
COPY package.json ./
COPY backend/package.json ./backend/
COPY frontend/package.json ./frontend/

# Install all dependencies for the monorepo.
# --legacy-peer-deps is used to avoid potential peer dependency conflicts
# between the different frameworks in the monorepo.
RUN npm install --legacy-peer-deps

# Copy the rest of the application source code
COPY . .

# Build both the backend and frontend applications for production
RUN npm run build --workspace=backend
RUN npm run build --workspace=frontend

# Switch to a non-root user for security
USER node

# The command to run tests. This will be executed by the QA stage.
# It assumes a root-level "test" script in package.json that runs tests
# for both workspaces.
CMD ["npm", "test"]
