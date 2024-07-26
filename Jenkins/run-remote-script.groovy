pipeline {

    agent any

    stages {

         stage('Remote login') {

             steps {

                 script {

                         def remote = [:]

                         remote.name = "testAppServer"

                         remote.host = "IP"

                         remote.port = PORT

                         remote.allowAnyHosts = true

                         withCredentials([sshUserPrivateKey(credentialsId: 'testAppServer', keyFileVariable: 'testAppServer', usernameVariable: 'testDev')]) {

                                 remote.user = testDev

                                 remote.identityFile = testAppServer
                                     sshCommand remote: remote, command: 'bash /home/testDev/testDev-eks-scaling/testDev-cluster-details.sh'

                           }

                    }

            }

         }

     }

}