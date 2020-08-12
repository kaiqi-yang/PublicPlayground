# Use an existing docker image as a base
FROM alpine

# Download an dinstall a dependency
RUN apk add --update redis

# Add a dummy dependency
RUN apk add --update gcc

# Tell the image what to do when it starts as a container
CMD ["redis-server"]