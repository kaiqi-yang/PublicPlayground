Section 5: Docker Compose with Multiple Local Containers
0 / 12|52min

49. App Overview
4min

50. App Server Starter Code
7min

51. Assembling a Dockerfile
3min

52. Introducing Docker Compose
6min

- docker compose
  - ![](docker%20compose.png)

53. Docker Compose Files
6min
- Docker container contains all the options we'd normally pass to docker-cli
  - ![](Docker%20compose%20file%20.png)
- basic structure
  - ![](basic%20structure%20of%20docker%20compose.png)

54. Networking with Docker Compose
5min
- ![](docker%20compose%20networking.png)

55. Docker Compose Commands
5min

- ![](Docker%20compose%20commands.png)
  - `docker-compose up`
  - `docker-compose up --build`
-  Docker compose will handle some networking
   -  docker compose networking

56. Stopping Docker Compose Containers
3min

- Launch in background
  - `docker-compose up -d`
- Stop Containers
  - `docker-compose down`

57. Container Maintenance with Compose
3min

58. Automatic Container Restarts
9min

- Status code for a process
  - `0`
    - we exited and everything is OK
  - `1, 2, 3, etc`
    - we exited because something went wrong

- Restart Policies in docker compose
  - `"no"`
    - never attempt to restart this container if it stops or crashes
    - This policy needs to be surrounded with double quotes or single quote because `no` in plain text means `false` in yaml. 
  - `always` 
    - If this container stops for any reason, always attempt to restart it
  - `on-failure`
    - Only restart if the container stops with an error code
  - `unless-stopped`
    - Always restart unless we (the developers) forcibly stop it

1.  Container Status with Docker Compose
2min

60. Completed Code for Section 5 Visits App
1min
