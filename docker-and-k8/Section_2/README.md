# Section 2: Manipulating Containers with
the Docker Client
0 / 14|51min

14. Docker Run in Detail
2min
## Docker run
- `docker run hello-world`

- `docker run <image> <command>`
  - The command will overwrite the default command after the container is started up.
  - ![](override%20command%20.png)
  - `docker run busybox echo hi there`
    - ![](busy%20box.png)
  - `docker run bosybox ls`
    - ![](busybox%20ls.png)
    - For the image busybox, the `ls` program is in the bin folder as part of the image. For the image `hello-world` the `ls` program is not included.

15. Overriding Default Commands
5min


16. Listing Running Containers
4min
- `docker ps`
  - To show all running containers
  - ![](docker%20ps.png)
- `docker ps --all`
  - To show all containers ever created 
  - ![](docker%20ps%20all.png)

17.  Container Lifecycle
5min
- `docker run` = `docker create` + `docker start`
  - ![](create%20and%20start%20a%20container.png)
  - `docker create`
    - Copying the FS snapshot
  - `docker start`
    - Executing the command 
    - ![](docker%20create%20and%20start.png)
    - `docker start -a <image id>`
      - the `-a` means to attach to the container and watch the output.

18. Restarting Stopped Containers
4min
- Restarting Stopped Containers using container ID
  - ![](Restarting%20Stopped%20Containers%20using%20container%20ID.png)
  - The command cannot be changed. 


19.  Removing Stopped Containers
2min
- `docker system prune`
  - ![](docker%20system%20prune.png)

20. Retrieving Log Outputs
3min
- `docker logs <container id>`
  - To get the logs
  - ![](docker%20log.png)

21. Stopping Containers
5min

- Stopping containers 
  - `docker stop <id>`
    - shut down gracefully
    - it will be killed after 10s
  - `docker kill <id>`
    - shut down right now

22. Multi-Command Containers
4min
- `docker run redis`
  - it starts a redis server, but we also need to start `redis-cli` to interact with it as showing below
  - ![](docker%20run%20redis.png)
23. Executing Commands in Running
Containers
3min
- `docker exec -it <container id> <command>`
  - ![](docker%20exec%20it.png)
- `docker exec -it 68cfdcff1c46 redis-cli`
  - ![](docker%20exec%20for%20redis%20cli.png)

24.  The Purpose of the IT Flag
5min
- processes in Linux
  - ![](processes%20in%20Linux.png)
    - each of them is attached to **communication channels**
      - STDIN
        - get the input from terminal
      - STDOUT
        - show up in the terminal
      - STDERR
        - for errors
- `-it` = `-i` + `-t`
  - `-i`
    - direct input in the terminal to the process
  - `-t` 
    - format the output
  - without the -t 
    - ![](without%20the%20-t.png)

25. Getting a Command Prompt in a Container
4min
- `docker exec -it 68cfdcff1c46 sh`
  - Get the terminal access inside of a terminal
  - Get out with `ctrl + D` or type in `exit`
  - ![](get%20terminal%20access%20with%20sh.png)


26.  Starting with a Shell
2min
- `docker run -it busybox sh`

27. Container Isolation
3min
- Containers don't share file system.