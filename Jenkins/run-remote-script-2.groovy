pipeline {

    agent any

    stages {

         stage('Remote login') {

             steps {

                 script {

                         def remote = [:]

                         remote.name = "bastion"

                         remote.host = "10.0.0.172"

                         remote.port = 22133

                         remote.allowAnyHosts = true

                         withCredentials([sshUserPrivateKey(credentialsId: 'reactapp', keyFileVariable: 'reactapp', usernameVariable: 'ubuntu')]) {

                                 remote.user = ubuntu

                                 remote.identityFile = reactapp

                                 stage("Git clone and Rsync") {

                                     sshCommand remote: remote, command: 'sudo git clone -b uat https://github.com/it-indusviva/iv_bo_new.git'

                                     sshCommand remote: remote, command: 'sudo rsync  -avz --progress iv_bo_new/ iv_bo-web-server'

                                     sshCommand remote: remote, command: 'sudo rm -rf iv_bo_new'

                                     sshCommand remote: remote, command: 'cd  iv_bo-web-server && pwd && ls -l'

                                    }  

                           }

                    }

            }

         }

     }

}