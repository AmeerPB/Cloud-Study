pipeline {
    agent any
    stages {
        stage('Remote login') {
            steps {
                script {
                    def remote = [:]
                    remote.name = "<USERNAME>"
                    remote.host = "<IP_ADDR>"
                    remote.port = <PORT>
                    remote.allowAnyHosts = true
                    withCredentials([sshUserPrivateKey(credentialsId: 'Testserver', keyFileVariable: 'keyFile', usernameVariable: 'user')]) {
                        remote.user = user
                        remote.identityFile = keyFile
                        sshCommand remote: remote, command: 'bash /home/ec2-user/test.sh'
                    }
                }
            }
        }
    }
    post {
        success {
            script {
                def webhookUrl = 'https://prod2-09.centralindia.logic.azure.com:443/workflows/593ade20b2a948e78fb827c1e0143114/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=yt5aYzG7C3dXI0A76d1uzIjKP2NwyulmHCbvedVSXcw' // Replace with your Teams webhook URL
                def payload = """{
                    "text": "Jenkins job succeeded: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                }"""
                httpRequest url: webhookUrl, httpMode: 'POST', contentType: 'APPLICATION_JSON', requestBody: payload
            }
        }
        failure {
            script {
                def webhookUrl = 'https://prod2-09.centralindia.logic.azure.com:443/workflows/593ade20b2a948e78fb827c1e0143114/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=yt5aYzG7C3dXI0A76d1uzIjKP2NwyulmHCbvedVSXcw' // Replace with your Teams webhook URL
                def payload = """{
                    "text": "Jenkins job failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                }"""
                httpRequest url: webhookUrl, httpMode: 'POST', contentType: 'APPLICATION_JSON', requestBody: payload
            }
        }
    }
}
