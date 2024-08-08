java -jar jenkins-cli.jar -s http://localhost:8080 -auth user:token quiet-down

curl http://localhost:8080/jnlpJars/jenkins-cli.jar -o /tmp/jenkins-cli.jar

jenkins@dc17ee5d3deb:/tmp$  java -jar jenkins-cli.jar -s http://localhost:8080 -auth user:token quiet-down
jenkins@dc17ee5d3deb:/tmp$  java -jar jenkins-cli.jar -s http://localhost:8080 -auth user:token cancel-quiet-down
