# diagram.py
from diagrams import Diagram,Cluster, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.compute import AutoScaling
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB
from diagrams.aws.management import Cloudwatch
from diagrams.aws.storage import S3

with Diagram("AIK Archicteture Diagram Solution", show=False):

    bucket = S3("Bucket x3")
    vpc = Cluster("VPC")
    
    with vpc:
        loadBal = ELB("ELB")    
        jenkins = EC2("Jenkins CI/CD Server")
        with Cluster("EC2 Instances - AutoScaling Group"):
            ec2_1 = EC2("AIK App")
            ec2_2 = EC2("AIK App")
        with Cluster("DB RDS MySQL"):
            rds = RDS("")
   

    rds << Edge(label="") >> ec2_1
    rds << Edge(label="") >> ec2_2
  
    loadBal >> ec2_1
    loadBal >> ec2_2
    
    ec2_1 >> bucket
    ec2_2 >> bucket
    ec2_1 << Cloudwatch("CloudWatch")

    
    