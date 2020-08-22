# Section 6: Creating a Production-Grade Workflow
0 / 29|1hr 35min

61. Development Workflow
1min

62. Flow Specifics
7min

63. Docker's Purpose
2min

64. Project Generation
3min

npx create-react-app frontend

65. Create React App Generation
1min

66. More on Project Generation
2min

67. Necessary Commands
5min

```
npm run start

npm run test

npm run build
```

68. Creating the Dev Dockerfile
4min

- The plan
  - ![](The%20plan%20for%20step%2068.png)
- Created the `Dockerfile.dev`
  - `docker build -f Dockerfile.dev .`



69. Duplicating Dependencies
1min

- The content to copy is very large because of the `/node_modules` folder that the `create-react-app` created. This is give us duplicated dependencies and it will slow down the docker build. 
  - We can remove the `/node_modules` folder to speed up the docker build.
  - ![](docker%20daemon.png)
  - Solution
    - ![](Remove%20the%20node%20modules%20folder.png)

70. React App Exits Immediately with Docker Run Command
1min

71. Starting the Container
3min
- command
    - ` docker run -it -p 3000:3000 CONTAINER_ID `

72. Docker Volumes
7min

- Set up auto update with new changes with Docker volumes
  - no longer copy the content
  - it can be understood as a reference to local folder
  - ![](Docker%20volumes.png)
- Command to use after docker volumes
  - `docker run -p 3000:3000 -v /app/node_modules -v $(pwd):/app <image id>` 
  - ![](Command%20to%20use%20to%20map%20docker%20volumes.png)
  

73.  Windows not Detecting Changes - Update
2min


74. Bookmarking Volumes
5min

- The error: the app will not start up
  - Because we don't have the `/node_module` folder in local, in docker when it tries to use the folder it will reference to nothing. 
  - ![](missing%20node%20module%20in%20diagram.png)
  - Solution
    - add `-v /app/node_modules`
    - This is a placeholder in workdir, it will not map to anything



75. React App Exited With Code 0
1min

4-1-2020

Recently, a bug was introduced with the latest Create React App version that is causing the React app to exit when starting with Docker Compose.

To Resolve this:

Add stdin_open property to your docker-compose.yml file

```
  web:
    stdin_open: true
```

Make sure you rebuild your containers after making this change with  docker-compose down && docker-compose up --build

https://github.com/facebook/create-react-app/issues/8688

https://stackoverflow.com/questions/60790696/react-scripts-start-exiting-in-docker-foreground-cmd

76.  Shorthand with Docker Compose
4min


77. Overriding Dockerfile Selection
2min

78. Windows not Detecting Changes - Docker Compose
1min

79. Do We Need Copy?
3min

80. Executing Tests
4min

- To run the test
  - Just append the command at the end of docker run to overwrite
    - `docker run <container id> npm run test`
    - add `-it` to interact with the `stdin`
  - Downside:
    - will always need to remember the container id


81.  Live Updating Tests
5min
- We can choose to attach to the existing container
  - `docker exec -it f6174ff88ff4 npm run test`
  - so that the test will be auto updating
    - ![](auto%20updating%20test.png)

82. Docker Compose for Running Tests
6min

- Docker compose for running tasks: 
  - Added a docker compose service for tests
    - so that a container will be started up to run tests
    - it will also support live updating for tests because of the volumes
    - ![](Added%20a%20docker%20compose%20service%20for%20tests.png)
  - Downside:
    - cannot interact with the container

83. Tests Not Re-running on Windows
1min

84. Attaching to Web container
1min

85. Shortcomings on Testing
9min

86. Need for Nginx
3min

87. Multi-Step Docker Builds
7min

88. Implementing Multi-Step Builds
7min

89. Running Nginx
2min