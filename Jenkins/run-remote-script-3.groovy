pipeline {
    agent any
    stages {
         stage('Remote login') {
             steps {
                 script {
                         def remote = [:]
                         remote.name = "<USERNAME>"
                         remote.host = "<IP>"
                         remote.port = <PORT>
                         remote.allowAnyHosts = true
                         withCredentials([sshUserPrivateKey(credentialsId: 'Testserver', keyFileVariable: 'Testserver', usernameVariable: 'ec2-user')]) {
                                 remote.user = ec2-user
                                 remote.identityFile = Testserver
                                     sshCommand remote: remote, command: 'bash /home/ec2-user/test.sh'
                           }
                    }
            }
         }
     }
}
