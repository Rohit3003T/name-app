# AWS 3-Tier DevOps Deployment

A simple containerized Flask application deployed on AWS using a highly available 3-tier architecture, Terraform, Docker, Amazon ECR, GitHub Actions, Auto Scaling, RDS PostgreSQL, Secrets Manager, and CloudWatch.

The application allows users to enter their name and stores the data in PostgreSQL. It also displays the private IP, AWS Region, and Availability Zone of the EC2 instance handling the request.

---

## Architecture

                         Internet
                            │
                            ▼
                    Application Load Balancer
                            │
             ┌──────────────┼──────────────┐
             │              │              │
             ▼              ▼              ▼
          EC2/AZ1         EC2/AZ2        EC2/AZ3
          Docker          Docker         Docker
          Flask           Flask          Flask
             │              │              │
             └──────────────┼──────────────┘
                            │
                            ▼
                     RDS PostgreSQL
                       Private Subnets


        GitHub
           │
           ▼
     GitHub Actions
           │
           ▼
      Amazon ECR
           │
           ▼
    ASG Instance Refresh
           │
           ▼
   New EC2 instances pull
       latest image


---

## What This Project Demonstrates

* AWS VPC networking
* Public and private subnets
* Multi-AZ application deployment
* Application Load Balancer
* EC2 Auto Scaling Group
* Docker containerization
* Amazon ECR
* PostgreSQL on Amazon RDS
* AWS Secrets Manager
* CloudWatch monitoring
* Terraform Infrastructure as Code
* GitHub Actions CI/CD
* GitHub OIDC authentication
* Automated EC2 instance refresh

Terraform allows the infrastructure to be defined and managed as code instead of manually creating resources through the AWS Console.

---

## Application

The application is built with:

* Python
* Flask
* PostgreSQL
* Docker

### Application Features

1. Enter a name.
2. Store the name in PostgreSQL.
3. Display previously stored names.
4. Provide a `/health` endpoint for the Application Load Balancer.
5. Display the EC2 private IP, AWS Region, and Availability Zone.

---

## AWS Infrastructure

### Networking

* VPC: `10.0.0.0/20`
* 3 Public Subnets
* 3 Private Subnets
* Internet Gateway
* NAT Gateway
* Public Route Table
* Private Route Table

### Application Layer

* Application Load Balancer
* EC2 Auto Scaling Group
* 3 Availability Zones
* Docker containers
* Flask application

### Database Layer

* Amazon RDS PostgreSQL
* Private DB subnet group
* Database Security Group
* Database is not publicly accessible

### Security

* Separate Security Groups for:

  * ALB
  * EC2
  * RDS
* SSH restricted to a specific public IP
* RDS accessible only from the EC2 Security Group
* Database credentials stored in AWS Secrets Manager
* GitHub Actions authenticates to AWS using OIDC

---

## CI/CD Pipeline

```text
Developer pushes code
        │
        ▼
   GitHub Repository
        │
        ▼
   GitHub Actions
        │
        ├── Build Docker image
        │
        ├── Test dependencies
        │
        ├── Login to Amazon ECR
        │
        ├── Push image to ECR
        │
        └── Start ASG Instance Refresh
                         │
                         ▼
                New EC2 instances
                         │
                         ▼
                  Pull latest image
                         │
                         ▼
                  ALB health check
                         │
                         ▼
                 Application updated
```

The deployment uses EC2 Auto Scaling instance refresh to replace instances with the updated configuration/image in a rolling process. AWS documents instance refresh specifically for rolling out updated AMIs or user-data/launch-template changes.

---

## Monitoring

CloudWatch monitors three important areas:

### EC2 CPU

Triggers when the average EC2 CPU utilization remains above 80% for two evaluation periods.

### ALB Health

Monitors the number of healthy application targets behind the load balancer.

### RDS CPU

Monitors CPU utilization of the PostgreSQL RDS instance.

This provides visibility into:

```text
Compute → EC2
Application Availability → ALB
Database Performance → RDS
```

---

## Secrets Management

Database connection information is stored in:

```text
AWS Secrets Manager
        │
        ▼
    name-app/rds
        │
        ▼
     EC2 User Data
        │
        ▼
   Docker Environment
        │
        ▼
   Flask Application
```


---



---

## Project Structure

```text
name-app/
│
├── app.py
├── requirements.txt
├── Dockerfile
├── README.md
├── .gitignore
│
├── templates/
│   └── index.html
│
└── terraform/
    ├── provider.tf
    ├── variables.tf
    ├── network.tf
    ├── security.tf
    ├── alb.tf
    ├── rds.tf
    ├── ecr.tf
    ├── iam.tf
    ├── launch_template.tf
    ├── autoscaling.tf
    ├── cloudwatch.tf
    └── outputs.tf
```

---


## Technologies

| Category         | Technology                |
| ---------------- | ------------------------- |
| Application      | Python / Flask            |
| Database         | PostgreSQL                |
| Container        | Docker                    |
| Cloud            | AWS                       |
| Infrastructure   | Terraform                 |
| CI/CD            | GitHub Actions            |
| Registry         | Amazon ECR                |
| Compute          | EC2 / Auto Scaling        |
| Load Balancing   | Application Load Balancer |
| Database Hosting | Amazon RDS                |
| Secrets          | AWS Secrets Manager       |
| Monitoring       | Amazon CloudWatch         |
| Networking       | VPC                       |
| Authentication   | GitHub OIDC               |

---

## Project Goal

The goal of this project is to demonstrate how a simple web application can be deployed using production-style DevOps practices:

**Code → Container → ECR → Automated Deployment → Load Balancer → Auto Scaling → Database → Monitoring**

The application itself is intentionally simple so that the focus remains on the infrastructure, deployment process, security, and automation.


## How to Run Locally

### Prerequisites

Make sure you have:

* Git
* Docker
* PostgreSQL

Docker packages the application and its Python dependencies into a container, so you don't need to install Python dependencies directly on your machine.

### 1. Clone the repository

```bash
git clone https://github.com/Rohit3003T/name-app.git
cd name-app
```

### 2. Create the PostgreSQL database

Create a PostgreSQL database named:

```text
nameapp
```
or in instance 
sudo systemctl status postgresql

sudo systemctl start postgresql

sudo -u postgres psql

\c nameapp

Then create the `names` table:

```sql
CREATE TABLE names (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
```

### 3. Build the Docker image

```bash
docker build -t name-app .
```

### 4. Run the application

Replace the database values with your local PostgreSQL credentials:

```bash
docker run -d \
  --name name-app \
  -p 5000:5000 \
  -e DB_HOST="host.docker.internal" \
  -e DB_NAME="nameapp" \
  -e DB_USER="postgres" \
  -e DB_PASSWORD="your_password" \
  -e DB_PORT="5432" \
  name-app
```

Docker's `-p` option publishes the container port to the host, allowing the application to be accessed from your browser.

### 5. Open the application

Visit:

```text
http://localhost:5000
```

### 6. Check the container

```bash
docker ps
```

View application logs:

```bash
docker logs name-app
```

### 7. Stop the application

```bash
docker stop name-app
```

Remove the container:

```bash
docker rm name-app
```

---

## Running the AWS Infrastructure

To deploy the complete AWS infrastructure using Terraform:

```bash
cd terraform

terraform init
terraform validate
terraform plan
terraform apply
```

After Terraform finishes, the Application Load Balancer URL can be obtained from the Terraform outputs or AWS Console.

The AWS deployment then follows:

```text
Terraform
    ↓
AWS Infrastructure
    ↓
ALB
    ↓
EC2 Auto Scaling Group
    ↓
Docker + Flask
    ↓
RDS PostgreSQL
```

### Destroy AWS Infrastructure

When finished testing:

```bash
terraform destroy
```


