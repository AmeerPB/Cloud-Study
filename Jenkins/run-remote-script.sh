pipeline {
    agent any
    stages {
        stage('Remote login') {
            steps {
                script {
                    def remote = [:]
                    remote.name = "<REMOTE-NAME>" # Just a descriptive name, no need for username
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
                def webhookUrl = '<WEBHOOK_URL>' // Replace with your Teams webhook URL
                def payload = """{
                    "type": "message",
                    "attachments": [
                        {
                            "contentType": "application/vnd.microsoft.card.adaptive",
                            "content": {
                                "type": "AdaptiveCard",
                                "body": [
                                    {
                                        "type": "TextBlock",
                                        "text": "Jenkins job succeeded: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                                    }
                                ],
                                "\$schema": "https://adaptivecards.io/schemas/adaptive-card.json",
                                "version": "1.0"
                            }
                        }
                    ]
                }"""
                httpRequest url: webhookUrl, httpMode: 'POST', contentType: 'APPLICATION_JSON', requestBody: payload
            }
        }
        failure {
            script {
                def webhookUrl = '<WEBHOOK_URL>' // Replace with your Teams webhook URL
                def payload = """{
                    "type": "message",
                    "attachments": [
                        {
                            "contentType": "application/vnd.microsoft.card.adaptive",
                            "content": {
                                "type": "AdaptiveCard",
                                "body": [
                                    {
                                        "type": "TextBlock",
                                        "text": "Jenkins job failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                                    }
                                ],
                                "\$schema": "https://adaptivecards.io/schemas/adaptive-card.json",
                                "version": "1.0"
                            }
                        }
                    ]
                }"""
                httpRequest url: webhookUrl, httpMode: 'POST', contentType: 'APPLICATION_JSON', requestBody: payload
            }
        }
    }
}
