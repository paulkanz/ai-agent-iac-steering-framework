# Example: Breaking Security Group Cross-Reference Cycles
# Architectural Pattern: Standalone Ingress/Egress Rule Resources (NIST SC-7)

# ------------------------------------------------------------------------------
# ❌ ANTI-PATTERN (What unconstrained AI agents frequently generate):
# Defining inline ingress/egress blocks that reference each other inside the
# aws_security_group resource causes perpetual dependency cycles and forces
# destructive resource recreations in Terraform plans.
# ------------------------------------------------------------------------------
# resource "aws_security_group" "alb" {
#   name = "alb-sg"
#   egress {
#     from_port       = 8000
#     to_port         = 8000
#     security_groups = [aws_security_group.app.id] # Cycle!
#   }
# }
# resource "aws_security_group" "app" {
#   name = "app-sg"
#   ingress {
#     from_port       = 8000
#     to_port         = 8000
#     security_groups = [aws_security_group.alb.id] # Cycle!
#   }
# }

# ------------------------------------------------------------------------------
# ✅ COMPLIANT PATTERN (What this steering framework enforces):
# 1. Clean security group shells with zero inline rules.
# 2. Standalone aws_vpc_security_group_ingress_rule / _egress_rule resources.
# 3. Clean topological graph resolution without cycles.
# ------------------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "enterprise-alb-sg"
  description = "Application Load Balancer perimeter security group"
  vpc_id      = "vpc-0123456789abcdef0"

  tags = {
    Name = "alb-security-group"
  }
}

resource "aws_security_group" "app" {
  name        = "enterprise-app-sg"
  description = "ECS Fargate application tasks security group"
  vpc_id      = "vpc-0123456789abcdef0"

  tags = {
    Name = "app-security-group"
  }
}

# Rule 1: Ingress from ALB to App on container port (8000)
resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "Admit container traffic from ALB security group only"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}

# Rule 2: Egress from ALB to App on container port (8000)
resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Forward HTTP traffic to ECS application tasks"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}
