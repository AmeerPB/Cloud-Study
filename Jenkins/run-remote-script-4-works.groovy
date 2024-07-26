# PipeLine works
# But the WebHook is NOt
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
}
