pipeline {
    agent any
    tools {
        maven 'maven3.9.11' 
    }
    environment {
        // The Account ID, Region, and Repository Name come from parameters/globals
        ECR_REPO_URI = "${params.AWS_ACCOUNT_ID}.dkr.ecr.${params.AWS_REGION}.amazonaws.com/${params.ECR_REPO_NAME}"
       
        IMAGE_TAG    = "build-${env.BUILD_NUMBER}"
    }

    stages {
        stage('1. cleanup') {
            steps {
                deleteDir()
            }
        }
        stage('2. Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/badrivarun02/Simple-CICD-BVD.git'
            }
        }
        stage('Security scan in sourcecode'){
            steps {
                sh 'trivy fs .'
            }
        }
        stage('3. Maven') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('4. Upload artifact to s3') {
            steps {

                withAWS(credentials: 'my-jenkins-aws-creds', region: 'us-east-2') {
                    sh 'aws s3 cp target/*jar s3://my-lambda-deploy-zips-2025/'
                    
                }
             }
           }
        stage('5. Docker build & tag') {
            steps {
                sh """
                  docker build -t ${ECR_REPO_URI} . 
                  docker tag ${ECR_REPO_URI}:latest ${ECR_REPO_URI}:${IMAGE_TAG}
                """
            }
        }
       
        stage('7. push to ECR'){
            steps{
                withAWS(credentials: 'my-jenkins-aws-creds', region: 'us-east-2') {
                     sh """
                        # 1. Get ECR login password using AWS CLI and pipe it to docker login
                        aws ecr get-login-password --region ${params.AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URI}
                        docker push ${ECR_REPO_URI}:latest
                        docker push ${ECR_REPO_URI}:${IMAGE_TAG}
                     """
                }
            
        
            }
        }
        
    }

}