FROM openjdk:8-jre-alpine 

ENV APP_HOME=/app
WORKDIR $APP_HOME
# Copy the 'devops-integration.jar' file from the '/workspace' directory in the 'builder' image 
# (the first stage) to the current directory in the Docker image.
COPY target/devops-integration.jar $APP_HOME/devops-integration.jar

# Set the default command for the Docker container to 'java -jar devops-integration.jar'. 
# This command will be run when a container is started from the Docker image.
ENTRYPOINT ["java", "-jar", "devops-integration.jar"]
