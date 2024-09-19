pipeline {
    agent any
    //agent {
    //    docker {
    //        image 'google/cloud-sdk:slim'
    //        args '-v /path/to/your/credentials:/root/.config/gcloud'
    //    }
    //}

    environment {
        // 定義環境變量
        DOCKER_CLI_EXPERIMENTAL = 'enabled'
        //您的GitHub存儲庫URL
        GIT_REPO = 'git@github.com:pcejks/jkspce_Sharon.git'
        //您的Docker Hub映像名稱
        DOCKER_IMAGE = 'pcejks/jkspce' //'your_dockerhub_username/your_image_name'
        //Docker Hub憑證ID，這需要在Jenkins中預先配置。
        DOCKER_CREDENTIALS_ID = 'a5a88dce-aa80-4289-b66b-577eb24dd9c3'//'dockerhub_credentials'
        //GitHub SSH憑證ID，這需要在Jenkins中預先配置。
        SSH_CREDENTIALS_ID = 'ca0d7de6-8dfc-4871-94e7-39681265d03f'//'github_ssh_credentials'
        GCP_PROJECT = "hip-watch-433914-q8"  //2024-08-28 新增
        GKE_CLUSTER = "autopilot-cluster-1" //2024-08-28 新增
        GKE_ZONE = "us-central1" //2024-08-28 新增
        GCP_CREDENTIALS = 'gcp-service-account'
        IMAGE = 'pcejks/jkspce:43'
    }

    stages {
        //使用SSH憑證從GitHub克隆存儲庫
        stage('Clone Repository') {
            steps {
                // 使用SSH憑證從GitHub獲取程式碼
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: "${GIT_REPO}", credentialsId: "${SSH_CREDENTIALS_ID}"]]])
            }
        }
        //使用Docker命令來構建映像
        stage('Build Docker Image') {
            steps {
                script {
                    // 使用Docker命令來構建映像
                    sh 'docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .'
                }
            }
        }
        
        //使用Docker插件和憑證將映像推送到Docker Hub
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        sh 'docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}'
                    }
                }
            }
        }


        stage('Pull Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        docker.image("${IMAGE}").pull()
                    }
                }
            }
        }

        stage('Deploy to GKE') {
            //steps {
            //    script {
                    // 設定 GCP 認證
            //        withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        // 認證到 GKE
            //            sh """
            //            gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
            //           gcloud config set project ${GCP_PROJECT}
            //            gcloud container clusters get-credentials ${GKE_CLUSTER} --zone ${GKE_ZONE}
            //            """
                        // 使用 kubectl 部署到 GKE
            //            sh """
            //            kubectl set image deployment/your-deployment-name your-container-name=${DOCKER_IMAGE}:latest
            //            """
            //        }
            //    }
            //}

            //sh '/usr/local/bin/gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS'
            steps {
                withEnv(['GCLOUD_PATH=/home/jenkins/JKs0000/google-cloud-sdk/bin']) {
                    sh '$GCLOUD_PATH/gcloud --version'
                
                    withCredentials([file(credentialsId: "${GCP_CREDENTIALS}", variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        script {
                            // 取得集群憑證
                            sh '$GCLOUD_PATH/gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS'
                            //sh "gclou/usr/local/bin/d auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}"
                            sh "$GCLOUD_PATH/gcloud container clusters get-credentials ${GKE_CLUSTER} --zone ${GKE_ZONE} --project ${GCP_PROJECT}"
                            
                            // 建立 Kubernetes 部署文件
                            sh """
                            cat <<EOF > deployment.yaml
                            apiVersion: apps/v1
                            kind: Deployment
                            metadata:
                            name: myapp-deployment
                            labels:
                                app: myapp
                            spec:
                            replicas: 2
                            selector:
                                matchLabels:
                                app: myapp
                            template:
                                metadata:
                                labels:
                                    app: myapp
                                spec:
                                containers:
                                - name: myapp
                                    image: ${IMAGE}
                                    ports:
                                    - containerPort: 80
                            EOF
                            """

                            // 部署到 GKE
                            sh "kubectl apply -f deployment.yaml"

                            // 曝露服務
                            sh """
                            cat <<EOF > service.yaml
                            apiVersion: v1
                            kind: Service
                            metadata:
                            name: myapp-service
                            spec:
                            selector:
                                app: myapp
                            ports:
                                - protocol: TCP
                                port: 80
                                targetPort: 80
                            type: LoadBalancer
                            EOF
                            """

                            sh "kubectl apply -f service.yaml"
                        }
                    }
                }
            }
        
        }

    }


    

    post {
        always {
            // 清理工作環境
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}



    