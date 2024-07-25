pipeline {

    agent any

    stages {

         stage('Remote login') {

             steps {

                 script {

                         def remote = [:]

                         remote.name = "bastion"

                         remote.host = "15.206.94.197"

                         remote.port = 8288

                         remote.allowAnyHosts = true

                         withCredentials([sshUserPrivateKey(credentialsId: 'Bastion', keyFileVariable: 'Bastion', usernameVariable: 'uat')]) {

                                 remote.user = uat

                                 remote.identityFile = Bastion
                                     sshCommand remote: remote, command: 'bash /home/uat/uat-eks-scaling/uat-cluster-details.sh'

                           }

                    }

            }

         }

     }

}