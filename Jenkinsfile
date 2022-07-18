pipeline {

    agent any

    options {
        timestamps()
        ansiColor('xterm')
        buildDiscarder logRotator(numToKeepStr: '100')
        disableConcurrentBuilds()
        timeout(activity: true, time: 1, unit: 'DAYS')
    }

    parameters {
        string defaultValue: 'master', description: 'Git branch to build', name: 'GIT_BRANCH', trim: true
        string defaultValue: 'git@github.com:balena-io-library/resin-rpi-raspbian.git', description: 'Git repository', name: 'GIT_URL', trim: true
        string defaultValue: 'resin-packages', description: 'AWS/S3 output bucket', name: 'BUCKET_NAME', trim: true
        credentials credentialType: 'com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl', defaultValue: '273bf5c6-1411-46c3-b0d5-6469e84d50ff', description: 'AWS/IAM credentials', name: 'AWS_CREDENTIALS', required: true
        credentials credentialType: 'com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey', defaultValue: 'a2d8eaf4-a373-4efa-a9e3-c331a3687e72', description: 'GitHub credentials', name: 'GIT_CREDENTIALS', required: true
        credentials credentialType: 'com.cloudbees.jenkins.plugins.credentialsbinding.MultiBinding', defaultValue: '3204255f-7677-4681-9f06-b4a2f804e2a2', description: 'DOCKERHUB CREDENTIALS', name: 'DOCKERHUB_CREDENTIALS', required: true
    }

    stage('scm') {
        steps {
            checkout([
                $class: 'GitSCM',
                branches: [[name: '*/${GIT_BRANCH}']],
                doGenerateSubmoduleConfigurations: false,
                extensions: [],
                submoduleCfg: [],
                userRemoteConfigs: [[
                    credentialsId: GIT_CREDENTIALS, 
                    url: GIT_URL
                ]
            ]])
        }
    }
    stages {
        stage('build') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding', 
                        accessKeyVariable: 'ACCESS_KEY', 
                        credentialsId: AWS_CREDENTIALS, 
                        secretKeyVariable: 'SECRET_KEY'
                    ],
                    [
                        $class: 'UsernamePasswordMultiBinding',
                        credentialsId: 'DOCKERHUB_CREDENTIALS',
                        usernameVariable: 'DOCKERHUB_USERNAME',
                        passwordVariable: 'DOCKERHUB_PASSWORD']
                ]) {
                    sh 'docker login -u "$DOCKERHUB_USERNAME" -p "$DOCKERHUB_PASSWORD"'
                    sh returnStdout: true, script: 'bash -x automation/jenkins-build.sh'
                }
            }
        }
    }
}
