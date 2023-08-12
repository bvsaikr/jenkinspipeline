pipeline{
    agent {
        label 'build_node'
    }

stages{
    stage("clone from git hub"){
     steps{
     cleanWs()
     git branch: '${GIT_BRANCH}',
    changelog: true, 
    credentialsId: '744e8ac1-709a-4342-b97b-4fa47bcebe43', 
    poll: true, 
    url: 'https://github.com/bvsaikr/be.git'
     }
    }
    stage("build"){
        steps{
        withMaven(globalMavenSettingsConfig: '', 
        jdk: 'java-17', 
        maven: 'mvnforbe', 
        mavenSettingsConfig: '', 
        traceability: true) {
         
        sh '''
             cd /home/ec2-user/workspace/be_app/be/springboot-backend
             mvn clean install
           '''
}
            
        }
    }
    
    stage("sonar scanner"){
        steps{
            script{
        withMaven(maven: 'mvnforbe'){
         withSonarQubeEnv('sonar'){
          
       sh '''
       cd /home/ec2-user/workspace/be_app/be/springboot-backend
       mvn sonar:sonar
       '''
         timeout(time: 5, unit: 'MINUTES') {
                        qg = waitForQualityGate() 
                        if (qg.status != 'OK') {
                            //currentBuild.result = 'UNSTABLE'
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
         }
         }
        }
            }
        
        }
     
}}
}
