#!groovy

pipeline
{
    agent any
    parameters {
        string(name: 'CONTAINER_HOSTNAME_TEST', defaultValue: 'test.thehotelcook.com', description: 'Configure the DNS name that the test container will use. This will allow the container to get a certificate with the right dns name.')

        string(name: 'CONTAINER_HOSTNAME_NON_PROD', defaultValue: 'staging.thehotelcook.com', description: 'Configure the DNS name that the non-production container will use. This will allow the container to get a certificate with the right dns name.')

        string(name: 'CONTAINER_HOSTNAME_PROD', defaultValue: 'prod.thehotelcook.com', description: 'Configure the DNS name that the production container will use. This will allow the container to get a certificate with the right dns name.')

        password(name: 'VAULT_API_KEY', defaultValue: 'REPLACEME', description: 'Enter your Vault API key')

        string(name: 'VAULT_ROLE_URL_NON_PROD', defaultValue: 'https://vault.thehotelcook.com:8200/v1/venafi-pki/issue/cloud-backend', description: 'Enter the URL to the Vault role that will be used to issue certificates used for non-production environments.')

        string(name: 'VAULT_ROLE_URL_PROD', defaultValue: 'https://vault.thehotelcook.com:8200/v1/venafi-pki/issue/cloud-backend-prod', description: 'Enter the URL to the Vault role that will be used to issue certificates used for production environments.')

        string(name: 'VAULT_PICKUP_URL', defaultValue: 'https://vault.thehotelcook.com:8200/v1/venafi-pki/cert/', description: 'Enter the URL for the Venafi Vault secrets engine.')
    }
    stages{
        stage('Stop existing test container and remove if it exists') {
            agent
            {
                node
                {
                        label 'jenkinsslave3cloud.eastus.cloudapp.azure.com'
                }
            }
            steps {
                sh "sudo docker stop some-nginx || true"
                sh "sudo docker rm some-nginx || true"
            }
        }
        stage('Checkout external proj for test') {
            agent
            {
                node
                {
                        label 'jenkinsslave3cloud.eastus.cloudapp.azure.com'
                }
            }
            steps {
                git branch: 'master',
                    credentialsId: 'da47127e-5a07-4787-a1f3-6d6130f131ef',
                    url: 'https://github.com/wgoulet/C4DO-Demo.git'

                sh "ls -lat"
                }
        }
        stage('Create DNS record for test container')
        {
         agent
            {
                node
                {
                        label 'jenkinsslave3cloud.eastus.cloudapp.azure.com'
                }
            }
            steps {
                sh "chmod +x createverifydns.sh"
                sh "./createverifydns.sh ${params.CONTAINER_HOSTNAME_TEST} jenkinsslave3cloud.eastus.cloudapp.azure.com Z182BBELG3E7UP"
            }
        }
        stage('Build container for test') {
            agent
            {
                node
                {
                        label 'jenkinsslave3cloud.eastus.cloudapp.azure.com'
                }
            }
            steps {
                sh "sudo docker build -t some-content-nginx ."
                }
        }
        stage('Deploy test container') {
            agent
            {
                node
                {
                        label 'jenkinsslave3cloud.eastus.cloudapp.azure.com'
                }
            }
            steps {
                sh "sudo docker run --name some-nginx -d -p 443:443 some-content-nginx ${params.CONTAINER_HOSTNAME_TEST} ${params.VAULT_API_KEY} ${params.VAULT_ROLE_URL_NON_PROD} ${params.VAULT_PICKUP_URL}"
                
                echo "Container deployed at https://${params.CONTAINER_HOSTNAME_TEST}"
            }
        }
        stage('Stop existing non-production container and remove if it exists') {
            agent
            {
                node
                {
                        label 'jenkinsslave1cloud.eastus.cloudapp.azure.com'
                }
            }
            steps {
                sh "sudo docker stop some-nginx || true"
                sh "sudo docker rm some-nginx || true"
            }
        }
        stage('Checkout external proj for non-prod') {
            agent
            {
                node
                {
                        label 'jenkinsslave1cloud.eastus.cloudapp.azure.com'
                }
            }
            steps {
                git branch: 'master',
                    credentialsId: 'da47127e-5a07-4787-a1f3-6d6130f131ef',
                    url: 'https://github.com/wgoulet/C4DO-Demo.git'

                sh "ls -lat"
                }
        }
        stage('Create DNS record for non-production container')
        {
         agent
            {
                node
                {
                        label 'jenkinsslave1cloud.eastus.cloudapp.azure.com'
                }
            }
            steps {
                sh "chmod +x createverifydns.sh"
                sh "./createverifydns.sh ${params.CONTAINER_HOSTNAME_NON_PROD} jenkinsslave1cloud.eastus.cloudapp.azure.com Z182BBELG3E7UP"
            }
        }
        stage('Build container for non-production') {
            agent
            {
                node
                {
                        label 'jenkinsslave1cloud.eastus.cloudapp.azure.com'
                }
            }
            steps {
                sh "sudo docker build -t some-content-nginx ."
                }
        }
        stage('Deploy non-production container') {
            agent
            {
                node
                {
                        label 'jenkinsslave1cloud.eastus.cloudapp.azure.com'
                }
            }
            steps {
                sh "sudo docker run --name some-nginx -d -p 443:443 some-content-nginx ${params.CONTAINER_HOSTNAME_NON_PROD} ${params.VAULT_API_KEY} ${params.VAULT_ROLE_URL_NON_PROD} ${params.VAULT_PICKUP_URL}"
                
                echo "Container deployed at https://${params.CONTAINER_HOSTNAME_NON_PROD}"
            }
        }
        stage('Stop existing production container and remove if it exists') {
            agent
            {
                node
                {
                        label 'jenkinsslave2cloud.eastus.cloudapp.azure.com'
                }
            }
            steps {
                sh "sudo docker stop some-nginx || true"
                sh "sudo docker rm some-nginx || true"
            }
        }
        stage('Checkout external proj') {
            agent
            {
                node
                {
                        label 'jenkinsslave2cloud.eastus.cloudapp.azure.com'
                }
            }
            steps {
                git branch: 'master',
                    credentialsId: 'da47127e-5a07-4787-a1f3-6d6130f131ef',
                    url: 'https://github.com/wgoulet/C4DO-Demo.git'

                sh "ls -lat"
                }
        }
        stage('Create DNS record for production container')
        {
         agent
            {
                node
                {
                        label 'jenkinsslave2cloud.eastus.cloudapp.azure.com'
                }
            }
            steps {
                sh "chmod +x createverifydns.sh"
                sh "./createverifydns.sh ${params.CONTAINER_HOSTNAME_PROD} jenkinsslave2cloud.eastus.cloudapp.azure.com Z182BBELG3E7UP"
            }
        }
        stage('Build container for production') {
            agent
            {
                node
                {
                        label 'jenkinsslave2cloud.eastus.cloudapp.azure.com'
                }
            }
            steps {
                sh "sudo docker build -t some-content-nginx ."
                }
        }
        stage('Deploy production container') {
            agent
            {
                node
                {
                        label 'jenkinsslave2cloud.eastus.cloudapp.azure.com'
                }
            }
            steps {
                sh "sudo docker run --name some-nginx -d -p 443:443 some-content-nginx ${params.CONTAINER_HOSTNAME_PROD} ${params.VAULT_API_KEY} ${params.VAULT_ROLE_URL_PROD} ${params.VAULT_PICKUP_URL}"
                echo "Container deployed at https://${params.CONTAINER_HOSTNAME_PROD}"
                
            }
        }
    }
}