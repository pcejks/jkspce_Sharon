pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials-id') // 在Jenkins憑證管理中配置的憑證ID
    }
    stages {
        stage('Docker Build and Push') {
            steps {
                script {
                    dir('demoProject') { //切換到指定的目錄
                        echo "dir demoProject pwd : ${pwd()}" //印出當前的工作目錄(用於偵錯和確認 Jenkins 正在預期的目錄中執行命令)
                        
                        //建置 Docker 映像 (docker image)。
                        //-t 參數指定映像的標籤，格式為 yourdockerhubusername/project:tag 。
                        //yourdockerhubusername 需替換為自己的 Docker Hub 用戶名；project 需替換為專案或映像的名字；tag ：標籤，指定映像版本的標籤(下面的latest表示最新版本)
                        sh 'docker build -t oxygen10080/jkspce:latest .' 
                        
                        //Docker 登入和推送映像
                        //這裡使用 echo 和管道 (|) 將 Docker Hub 密碼傳遞給 docker login 命令。
                        // -u 參數後面跟著使用者名，--password-stdin 表示密碼透過標準輸入接收
                        // $DOCKER_HUB_CREDENTIALS_USR 和 $DOCKER_HUB_CREDENTIALS_PSW 是在 Jenkins 中配置的環境變量，儲存 Docker Hub 的使用者名稱和密碼
                        // docker push 將建置好的 Docker 映像推送到 Docker Hub，使得這個映像可以被公開存取或在多個環境中部署。
                        sh """
                        echo $DOCKER_HUB_CREDENTIALS_PSW | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin
                        docker push oxygen10080/jkspce:latest
                        """
                    }
                }
            }
        }
    }
}