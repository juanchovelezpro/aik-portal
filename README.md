
The following diagram represents a solution for this project (AIK).

![Diagram Solution](https://github.com/juanchovelezpro/aik-portal/blob/diagram/archicteture_diagram_solution_aik.png?raw=true "Diagram Solution")

The diagram was generated with the tool Diagrams (a package for Python)

## Getting Started
To generate the diagram you should have installed Python and pip.
You can install Diagrams with the following script using pip3

`$ pip install diagrams`

Now you can execute the next code to generate the diagram solution with the script 

`$ python diagram.py`

### Code

	# diagram.py
	from diagrams import Diagram,Cluster, Edge
	from diagrams.aws.compute import EC2
	from diagrams.aws.compute import AutoScaling
	from diagrams.aws.database import RDS
	from diagrams.aws.network import ELB
	from diagrams.aws.management import Cloudwatch
	from diagrams.aws.database import DB
	from diagrams.aws.storage import S3

		with Diagram("AIK Archicteture Diagram Solution", show=False):

    
    dynamo = DB("Dynamo DB")
    cluster = Cluster("EC2 Instances - AutoScaling Group")
    
    autoScal = AutoScaling("AutoScaling")
    loadBal = ELB("ELB")
    bucket = S3("Bucket")
    
    
    with cluster:
        ec2_1 = EC2("EC2 Web Server")
        ec2_2 = EC2("EC2 App Server")
        
    
    dynamo << Edge(label="") >> ec2_1
    loadBal >> ec2_1
    loadBal >> ec2_2
    
    ec2_1 >> autoScal
    ec2_2 >> autoScal
    
    ec2_1 >> bucket
    ec2_1 << Cloudwatch("Instance CloudWatch")



