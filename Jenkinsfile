pipeline {
    agent any

    environment {
        // 定義環境變量
        //您的GitHub存儲庫URL
        GIT_REPO = 'git@github.com:pcejks/jkspce_Sharon.git'
        //您的Docker Hub映像名稱
        DOCKER_IMAGE = 'pcejks/jkspce' //'your_dockerhub_username/your_image_name'
        //Docker Hub憑證ID，這需要在Jenkins中預先配置。
        DOCKER_CREDENTIALS_ID = 'dockerhub'//'dockerhub_credentials'
        //GitHub SSH憑證ID，這需要在Jenkins中預先配置。
        SSH_CREDENTIALS_ID = 'sshkey'//'github_ssh_credentials'
    }

    stages {
        //使用SSH憑證從GitHub克隆存儲庫
        stage('Clone Repository') {
            steps {
                // 使用SSH憑證從GitHub獲取程式碼
                git credentialsId: "${SSH_CREDENTIALS_ID}", url: "${GIT_REPO}"
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