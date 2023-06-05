# vpc

- It would be better if we use tool like atlantis to deploy and terragrunt to organize the code more than the current code.

- The terraform state should be pushed on remote store like s3.

- I automatically create subnet cidr using cidrsubnet function by adding the index of the azs to it, it can be also added manually everytime by setting the value of the variable for each environmet depending on our needs.

- I would use the official module of aws to create the vpc.

- It would be better if I added pre-commit to add some validation and securit checks.