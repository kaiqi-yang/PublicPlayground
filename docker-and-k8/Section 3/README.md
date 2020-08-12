# Section 3: Building Custom Images Through Docker Server
0 / 9|47min

28. Creating Docker Images
3min
- Docker file
  - ![](docker%20file.png)
- Creating a Dockerfile
  - ![](Creating%20a%20Dockerfile.png)

29. Building a Dockerfile
5min


- Create an image that runs redis-server
  - check the file `redis-image/Dockerfile`
  - run `docker build .`
    - output will contain: `Successfully built f6d5ec78590a`
  - run `docker run f6d5ec78590a`
    - ![](results%20for%20the%20dockerfile.png)
    - 

30. Dockerfile Teardown
3min

- ![](Dockerfile%20Teardown.png)
  - `FROM`
  - `RUN`
  - `CMD`


31. What's a Base Image?
6min
- Why do we use alpine as a base image?
  - They come with a preinstalled set of programs that are very useful to you!
  - `apk` is built into `alpine`

32. The Build Process in Detail
11min

- `docker build .`
  - For each of the step, except for the first one, `docker build` start a intermediate containers to run the `RUN` instruction as the main command.
  - After running the command, we take a snapshot of the container to create a new image which will be feed into the next step as a starting point.
  - Then continue on
    - ![](build%20process%20for%20docker%20file.png)

33.  A Brief Recap
3min


34. Rebuilds with Cache
7min

35. Tagging an Image
4min

36. Manual Image Generation with Docker
Commit
5min