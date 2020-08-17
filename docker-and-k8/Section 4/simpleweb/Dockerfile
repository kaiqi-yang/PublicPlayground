# Specify a base image
# this is a image already configured with node
# From <repo name>:<tag name>
# "alphine" is the named of a compact and strip down version of the image.
FROM node:alpine

# To avoid copying everything into the root folder
WORKDIR /usr/app

# Install some depenendencies
# COPY ./package.json ./

# Copy everything to the docker conatiner
COPY ./ ./
RUN npm install
# COPY ./ ./

# Default command
CMD ["npm", "start"]