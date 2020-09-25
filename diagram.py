# diagram.py
from diagrams import Diagram,Cluster, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.compute import AutoScaling
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB
from diagrams.aws.management import Cloudwatch
from diagrams.aws.storage import S3

with Diagram("AIK Archicteture Diagram Solution", show=False):

    
    rds = RDS("DB-RDS MySQL")

    
    autoScal = AutoScaling("AutoScaling")
    loadBal = ELB("ELB")
    bucket = S3("Bucket 1")
    bucket2 = S3("Bucket 2")
    bucket3 = S3("Bucket 3")
    vpc = Cluster("VPC")
    
    with vpc:
        with Cluster("EC2 Instances - AutoScaling Group"):
            ec2_1 = EC2("EC2 Web Server")
            ec2_2 = EC2("EC2 App Server")
        
    
    rds << Edge(label="") >> ec2_1
    rds << Edge(label="") >> ec2_2
    
    loadBal >> ec2_1
    loadBal >> ec2_2
    
    ec2_1 >> autoScal
    ec2_2 >> autoScal
    
    ec2_1 >> bucket
    ec2_1 >> bucket2
    ec2_1 >> bucket3
    ec2_1 << Cloudwatch("Instance CloudWatch")

    
    