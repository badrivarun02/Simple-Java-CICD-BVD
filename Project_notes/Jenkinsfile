// JENKINS CI PIPELINE/
// Purpose: The Code will be built into executable file (.jar) & pushed to Dockerhub


pipeline {
    agent any // This pipeline can be executed on any available agent
     // DECLARE THE VARIABLES HERE:
    environment {
        DOCKER_USERNAME = "badrivarun"     // docker username
          

    }

    stages {
        stage ("1. Cleanup") {
            // Clean workspace directory for the current build
            steps {
                deleteDir ()     // Deletes the current directory in a workspace        
            }
           }
         
        stage ('2. Git Checkout') {
            // use pipeline syntax generator to generate below step
            // 'Pipeline syntax' --> Steps 'Smaple step' --> git (enter url & branch & generate)
            steps {
                // Checks out code from the specified git repository
                git branch: 'main', url: 'https://github.com/badrivarun02/Simple-CICD-BVD.git'
                
            }
        } 
        stage("3. Maven Unit Test") {  
            // Test the individual units of code 
            steps{
                 // Executes the maven command for unit testing
                  bat 'mvn test'        
                }
        }
        

        stage('4. Maven Build') {
            // Build the application into an executable file (.jar)
            steps{
               // Executes the maven command for building the project
                  bat 'mvn clean install'   
                }
        }
        

        stage("5. Maven Integration Test") {
            //  Test the interaction between different units of code
            steps{
                // Executes the maven command for integration testing
                  bat 'mvn verify'          
                }
        }
        
        stage('archive and test result'){
          steps{
            // Archives the artifacts (in this case, .jar files)
            archiveArtifacts artifacts: '**/*.jar', followSymlinks: false
            }
        
        }

        stage('6. Docker Image Build and tag ') {
          steps{
           script {
                def JOB = env.JOB_NAME.toLowerCase() // Convert Jenkins job name to lowercase
                withCredentials([usernamePassword(credentialsId: 'dockerpwd', passwordVariable: 'dockerp', usernameVariable: 'dockeruser')]) {
                        // Login into Docker account
                        bat "docker login -u %dockeruser% -p %dockerp%"   // We can also use like this- bat "docker login -u ${dockeruser} -p ${dockerp}"
                // Build the Docker image
                        bat "docker build -t ${JOB}:${BUILD_NUMBER} ."
                // Tag the Docker image
                        bat "docker tag ${JOB}:${BUILD_NUMBER} ${DOCKER_USERNAME}/${JOB}:v${BUILD_NUMBER}"
                        bat "docker tag ${JOB}:${BUILD_NUMBER} ${DOCKER_USERNAME}/${JOB}:latest"                    
             }
          }
        }
        }
        stage('7. Trivy Image Scan') {
            // Scan Docker images for vulnerabilities 
            steps{
                script { 
                  def JOB = env.JOB_NAME.toLowerCase() // Convert Jenkins Job name to lower-case
                  // Scan the Docker image using Trivy
                  bat "trivy image  ${DOCKER_USERNAME}/${JOB}:v${BUILD_NUMBER} > scan.txt"
                }
            }
        }
        stage('8. Docker Image Push') {
            // Login to Dockerhub & Push the image to Dockerhub
            steps{
                script { 
                    def JOB = env.JOB_NAME.toLowerCase() // Convert Jenkins job name to lowercase
                
                // Method:1 
                    // withDockerRegistry(credentialsId: 'dockerpwd') {
                    //     bat "docker push ${DOCKER_USERNAME}/${JOB}:v${BUILD_NUMBER}" 
                    // }
                    // Method:2
                    // Convert Jenkins job name to lowercase
                    
                        // Push the Docker image to Dockerhub

                        bat "docker push ${DOCKER_USERNAME}/${JOB}:v${BUILD_NUMBER}"
                        bat "docker push ${DOCKER_USERNAME}/${JOB}:latest"
                      
                  }
                }
            }
        
    

        stage('9. Docker Image Cleanup') {
            // Remove the unwanted (dangling) images created in Jenkins Server to free-up space
            steps{
                script { 
                    // This command removes all unused images not just dangling ones
                  bat "docker image prune -af"
                }
            }
        }
        stage("deploy onto kubernetes"){
            steps{
                // This step uses the Kubernetes configuration file to deploy the application
                withCredentials([file(credentialsId: 'config', variable: 'CA_CERTIFICATE')]) {
                    kubeconfig(
                        credentialsId: 'config',
                        serverUrl: '',
                        caCertificate: '%env.CA_CERTIFICATE%'
                    ) {
                         // Apply the Kubernetes configuration files
                        bat 'kubectl apply -f SAforJenkins.yaml -f deployment.yaml -f service.yaml'
                        // Get the status of all Kubernetes resources
                        bat 'kubectl get all'
                    }
                }
            }
        }  
    }
    
    
    post {
    always {
        script{
                  // Format the build timestamp
                env.BUILD_TIMESTAMP = new Date(currentBuild.startTimeInMillis).format('MMMM dd, yyy | hh:mm:ss aaa | z')
            }
            // Send an email with the build report
        emailext (
            subject: "${currentBuild.currentResult} Build Report as of ${BUILD_TIMESTAMP} — ${env.JOB_NAME}",
            body: """The Build report for ${env.JOB_NAME} executed via Jenkins has finished its latest run.

- Job Name: ${env.JOB_NAME}
- Job Status: ${currentBuild.currentResult}
- Job Number: ${env.BUILD_NUMBER}
- Job URL: ${env.BUILD_URL}

Please refer to the build information above for additional details.

This email is generated automatically by the system.

Thanks""",
            recipientProviders: [[$class: 'DevelopersRecipientProvider']],
            to: 'badrivarun09@gmail.com',
            attachLog: true
        )
    }
}
}

    
     
    
       

    

        
        
