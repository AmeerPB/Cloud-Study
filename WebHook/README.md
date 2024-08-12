### Webhook related codes


> [!NOTE]
> #### Sample Teams message card template

``` yaml

{
    "type": "message",
    "attachments": [
        {
            "contentType": "application/vnd.microsoft.card.adaptive",
            "content": {
                "type": "AdaptiveCard",
                "body": [
                    {
                        "type": "TextBlock",
                        "text": "Hi <at>{USER-A-NAME}</at> <at>{USER-B-NAME}</at> Woo, workflows!"
                    }
                ],
                "$schema": "https://adaptivecards.io/schemas/adaptive-card.json",
                "version": "1.0",
                "msteams": {
                    "entities": [
                        {
                            "type": "mention",
                            "text": "<at>{USER-A-NAME}</at>",
                            "mentioned": {
                                "id": "{TEAMS-A-USER-KEY}",
                                "name": "{USER-A-NAME}"
                            }
                        },
                        {
                            "type": "mention",
                            "text": "<at>{USER-B-NAME}</at>",
                            "mentioned": {
                                "id": "{TEAMS-B-USER-KEY}",
                                "name": "{USER-B-NAME}"
                            }
                        }
                    ]
                }
            }
        }
    ]
}

```







> [!NOTE]
> #### Complete Jenkins Groovy code with teams webhook message card

``` yaml
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
                    withCredentials([sshUserPrivateKey(credentialsId: '<CREDENTIAL-ID>', keyFileVariable: 'keyFile', usernameVariable: 'user')]) {
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


```