# ccs-scale-infra-db-bat

## SCALE Buy a Thing (BaT) databases

### Overview
This repository contains a complete set of configuration files and code to deploy SCALE shared service databases into the AWS cloud.  The infrastructure code is written in [Terraform](https://www.terraform.io/).


### Prerequisites

Ensure that the following SSM parameters have been configured in AWS:

```
/bat/{env}-spree-db-master-username
/bat/{env}-spree-db-master-password

/bat/{env}-spree-db-app-username
/bat/{env}-spree-db-app-password
```

### Post Create

After the database has been provisioned, we need to create a user for the spree application to use to connect.

```
CREATE USER {USERNAME} WITH ENCRYPTED PASSWORD '{PASSWORD}';
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO {USERNAME};
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO {USERNAME};
GRANT ALL PRIVILEGES ON DATABASE spree TO {USERNAME};
```

Note: the values for {USERNAME} and {PASSWORD} need to match those that have been set in the following SSM parameters in AWS:

```
/bat/{env}-spree-db-app-username
/bat/{env}-spree-db-app-username
```