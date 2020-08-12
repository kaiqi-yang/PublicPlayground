# Use an existing docker image as a base
FROM alpine

# Download an dinstall a dependency
RUN apk add --update redis

# Tell the image what to do when it starts as a container
CMD ["redis-server"]