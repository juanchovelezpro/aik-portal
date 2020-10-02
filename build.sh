cd aik-app-api
docker build -t aik-backend:1.0.0 .
cd ..
cd aik-app-ui
docker build -t aik-frontend:1.0.0 .
cd .. 
terraform init
terraform plan
terraform apply