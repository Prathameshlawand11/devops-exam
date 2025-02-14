pipeline{
    agent any
    environment {
    AWS_REGION = 'ap-south-1'
    LAMBDA_FUNCTION_NAME = 'lambda_func6'
}
    stages{
        stage("TF Init"){
            steps{
                echo "Executing Terraform Init"
                 sh 'rm -rf .terraform .terraform.lock.hcl'
                sh 'terraform init -reconfigure'
            }
        }
        stage("TF Validate"){
            steps{
                echo "Validating Terraform Code"
                sh 'terraform validate'
            }
        }
        stage("TF Plan"){
            steps{
                echo "Executing Terraform Plan"
                sh 'terraform plan -target=aws_route_table_association.PrivateToPrivate'

            }
        }
        stage("TF Apply"){
            steps{
                echo "Executing Terraform Apply"
                sh 'terraform apply -auto-approve'
            }
        }

        

        stage("Invoke Lambda"){
            steps{
                echo "Invoking your AWS Lambda"

                 script {
                    def subnetId = sh(script: 'terraform output -raw subnet_id', returnStdout: true).trim()
                    echo "Subnet ID: ${subnetId}"
         sh """
aws lambda invoke \
--function-name ${LAMBDA_FUNCTION_NAME} \
--region ${AWS_REGION} \
--cli-binary-format raw-in-base64-out \
--payload '{ "subnet_id":"${subnetId}" }' \
response.json --log-type Tail
"""

          output = readFile('response.json')
          
        }
            }
        }
    }
}
