# securityjourney

## Context

Congratulations! You and your buddies just graduated college and have an amazing new idea for a startup: “The Costco hotdog price tracker”.  This app allows hungry patrons to figure out which Costco has the best price for food-court hotdogs without the need to drive all over town.  For inspiration, you folks were looking sites like GasBuddy and McBroken.
 
After your last final, you’re hanging out in your dorm room trying to figure out how to turn this amazing idea into the next billion-dollar Unicorn **(that will naturally never make a profit)** .     
Your buddy fires up their laptop and shows you the ‘hello-world’ version of the product and it’s your turn to get it into production.
 
When your buddy hands it off to you on a flash drive, you notice they have a Dockerfile they used in their local environment.
 
**Question 1:**
 
Please look at their Dockerfile  (attached) and:
1.	Summarize how you think the application works and identify any major components we’ll need to deploy.
    
    The entire application have 5 components. 
    - Database to store locations, hotdog prices, etc. 
    - Go app as the web scraper for prices
    - Nginx as proxy server to serve either static content or requests to the rails app
    - Rails app that compares the prices scraped and gets the best price in nearby food-courts
    - Crond that runs the go scraper at scheduled intervals. 

2.	Identify any smells or danger zones in the Dockerfile and indicate what you would do to improve them.
    
    Where to begin?  
    1. Docker is meant to run one process only, but this dockerfile combines all the components into 1 container. No individual component scalability.  First thing to do is to break the Dockerfile down into different Dockerfiles. Please see the additional dockerfiles as to how I would go about in breaking them out. 
    2. The resultant docker image doesn't have dedicated app users running these apps, so all the apps would run as root with potential security implications. 
    3. I'm not sure if we want to run the database in containers. This might be a great way of running dev environment but for production it may be a wise move to first run them via a service (like RDS or Google Cloud SQL), OR run hosted instances on Database servers with elastic storage backing them with snapshot capabilities. This is where my experience limitations shows, I've not worked at a place where database are run in a container to know what has to happen with regards to good backup and availability. 
    4. There's no SSL certificates being served by Nginx here, so that has to be rectified. Or have it be hooked up to to k8s or ECS with a dedicated ingress layer that serves the domain's certfiicates. 
    5. Are there any database authentications here?  Given that nothing is mentioned in the dockerfile it is possible that the logins to the database is hard coded and embedded into code and that should be stored in as a secret and not be checked into the codebaase repo.
    6. The cron scraper should be run using a container task scheduler and not be run with a cron daemon inside a docker container. So that cron would be eliminated immediately if running on kubernetes and instead be run as cronjob workload.

3.	Remix this Dockerfile into something that can be deployed in an AWS and Kubernetes based environment.
    Please see all dockerfiles in this repo not named `orig.dockerfile`
4.	Your buddy still needs a local development environment.  How would you align his local environment with your new production environment?
    Assuming we broke everything out in its own docker images, we would need a docker-compose file to run all apps at the same time to setup local dev environment, with the database store the data in local laptop folder that's separate from the codebase, or a folder that's gitignored within the codebase. Please see the docker-compose.yml file in the repo. 
    For staging environment, it is possible to deploy a different staging environment per developer in their own namespace (assuming the organization have enough money to do so)
 
Please return a Zip file including any project files you draft up.  We do not expect a fully working/deployable project.  As such, use your best judgement on where to include detail and where to stub things out.  
 
**Question 2:**
 
1.	As you were working through Question 1 what process, controls, tooling, features or automation did you need to solve as part of shipping this app and what did you consider but decide to defer?
    At this point of the startup, you're more likely losing investor money to create a proof of concept instead of losing money with unreliable serving to customers (since you have none). So I would prioritize on getting good developer experience to increase efficiency of app building over production serving needs. 
    1. I would first create a rudimentary staging/production environment (most likely by hand if that's the quickest, or generate a bunch of terraform files via AI to create a basic serving environment), with enough time spent for proper IAM authentication and authorization permissions and network security rules in place. 
    2. I would then add CI/CD pipeline to run tests and build docker images, publish said image to image repository, and deployment staging/production environment. 
    3. This is more of a developer's perview... but I would insist upon them developing some sort of pull request process, bug filing process, adding ample logging, agile development ceremonies (just enough of them, because you can go overboard) that makes sense to tackle backlogs and feature builds. 
    4. I would investigate a few software-as-service solutions for the following development needs, listed in the order of priority (Self-hosted solution at this stage is not practical)
        - Centralized logging aggregation for ease of access of logs. 
        - Automated documentation generation in the CI/CD pipeline (Lots of AI apps now a days for that)
	    - Security vulnerability scanning of applications (while not a priority at this point, it is also easy to start immediately and address as issue comes up, rather than punting this until later when software becomes too complex and vulnerability issues become a major project to tackle)
	    - Secrets handling.
	    - Service health alerting tools for production and some necessarly staging services to ensure good development flow, and simple service up/down and disk usage, would help. 
    
2.	What problems did/would these items solve?
    Ease and speed of development and deployment. I think the security scanning aspect will 

3.	What guided your decision to visit them ‘now’ or ‘later’?
    As stated, scaling is not an issue at this point in time. The `Now` vs. `Later` decision is entirely driven by development speed rather than production serving needs (without capping the ability to scale later on). So scaling, performance measurement, caching, on-call process, would be a later problem. While security or documentation isn't an immediate concern, but doing it correctly starting day 1 will only slightly longer but the benefit gain builds over time. I would focus on logging now more than metrics measurement. I can imagine that later on we might need caching needs (be it web assets, or the pricing invalidations), or database connection proxying. 

4.	For the deferred items, what timeframe would you anticipate until they become ‘now’ problems?
    This is highly dependent upon the business development, whether the proof of concept can attract more venture investment to grow the engineering department. A good process created for multi-party collaboration should last you a while before needing for adjustment. A good timeline would be 6 months? However... I've only been in startups where things went south within 6 months of me joining (or acquired) so yeah, ENTIRELY DEBATABLE. Honestly, I can't imagine what it was like working at Pinterest where it shot up within less than 6 months after it went viral. 
