Section 4: Making Real Projects with Docker
0 / 12|54min

37. Project Outline
3min

![](Project%20Outline.png)

38. Node Server Setup
5min

39. A Few Planned Errors
5min

40. Base Image Issues
8min

41. A Few Missing Files
3min

42. Copying Build Files
5min

![](Copying%20build%20files%20.png)

43. Reminder for Windows Home / Docker Toolbox Students
1min

44. Container Port Mapping
7min

- The container is able to access the internet by default.

- Port mapping 
  - ![](port%20mapping%20.png)


45.  Specifying a Working Directory
8min
- Using `COPY ./ ./` will copy everything into the root folder, which is not a good practice because it will cause problems when it conflicts with folders in the root. 
  - ![](Not%20using%20working%20directory.png)
  - `WORKDIR /usr/app`
    - Any following command will be executed relative to this path in the container.
    - The older will be created if not exist

46. Unnecessary Rebuilds
4min

47. Minimizing Cache Busting and Rebuilds
5min

In the example, the following changes have been made. Which means that only changing `./package.json` will require a rebuild for step `npm install`.
![](the%20changes%20to%20stop%20cache%20busting.png)

48. Completed Code for Section 4
1min
