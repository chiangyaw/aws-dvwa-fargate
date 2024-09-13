# Create a VPC
resource "aws_vpc" "dvwa_vpc" {
  cidr_block = var.cidr_block
}

# Create an Internet Gateway
resource "aws_internet_gateway" "dvwa_igw" {
  vpc_id = aws_vpc.dvwa_vpc.id
}

# Create a Subnet
resource "aws_subnet" "dvwa_subnet" {
  vpc_id            = aws_vpc.dvwa_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 1)
  map_public_ip_on_launch = true
}

# Create a route table
resource "aws_route_table" "dvwa_route_table" {
  vpc_id = aws_vpc.dvwa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dvwa_igw.id
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "dvwa_route_assoc" {
  subnet_id      = aws_subnet.dvwa_subnet.id
  route_table_id = aws_route_table.dvwa_route_table.id
}

# Create a Security Group
resource "aws_security_group" "dvwa_sg" {
  vpc_id = aws_vpc.dvwa_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "dvwa_cluster" {
  name = "dvwa-cluster"
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create ECS Task Definition
resource "aws_ecs_task_definition" "dvwa_task" {
  family                   = "dvwa-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "dvwa-container"
      image     = "vulnerables/web-dvwa"
      essential = true
      entryPoint = ["/main.sh"]
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# Create ECS Service
resource "aws_ecs_service" "dvwa_service" {
  name            = "dvwa-service"
  cluster         = aws_ecs_cluster.dvwa_cluster.id
  task_definition = aws_ecs_task_definition.dvwa_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.dvwa_subnet.id]
    security_groups = [aws_security_group.dvwa_sg.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy
  ]
}

resource "time_sleep" "wait_for_dvwa_service_pip"{
    create_duration = "300s"
    depends_on = [aws_ecs_service.dvwa_service]
}

# Fetch the ENI (Elastic Network Interface) ID of the Fargate task
data "aws_network_interface" "dvwa_eni" {
  
  filter {
    name   = "subnet-id"
    values = [aws_subnet.dvwa_subnet.id]
  }

  depends_on = [time_sleep.wait_for_dvwa_service_pip]

}

# Output public IP for fargate service
output "fargate_service_pip" {
    value = data.aws_network_interface.dvwa_eni.association[0].public_ip
}