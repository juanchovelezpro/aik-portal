
provider "docker" {
  version = "~> 2.7"
  host    = "npipe:////.//pipe//docker_engine"
}

resource "docker_container" "frontend"{
    image = docker_image.image_frontend.latest
    name = "container_frontend"
    attach = false
    ports {
        internal = var.port_front
        external = var.port_front
    }
}

resource "docker_container" "backend"{
    image = docker_image.image_backend.latest
    name = "container_backend"
    attach = false
    ports {
        internal = var.port_back
        external = var.port_back
    }
}

resource "docker_image" "image_frontend"{
 
    name = "aik-frontend:1.0.0"
}


resource "docker_image" "image_backend"{

    name = "aik-backend:1.0.0"
}