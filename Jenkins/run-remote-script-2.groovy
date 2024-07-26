pipeline {

    agent any

    stages {

         stage('Remote login') {

             steps {

                 script {

                         def remote = [:]

                         remote.name = "<name>"

                         remote.host = "<IP>"

                         remote.port = <PORT>

                         remote.allowAnyHosts = true

                         withCredentials([sshUserPrivateKey(credentialsId: 'testApp', keyFileVariable: 'testApp', usernameVariable: 'ubuntu')]) {

                                 remote.user = ubuntu

                                 remote.identityFile = testApp

                                 stage("Git clone and Rsync") {

                                     sshCommand remote: remote, command: 'sudo git clone -b uat https://github.com/<>.git'

                                     sshCommand remote: remote, command: 'sudo rsync  -avz --progress <>'

                                     sshCommand remote: remote, command: 'sudo rm -rf <>'

                                     sshCommand remote: remote, command: 'cd  <>'

                                    }  

                           }

                    }

            }

         }

     }

}