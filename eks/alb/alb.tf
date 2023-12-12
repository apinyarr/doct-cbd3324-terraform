module "alb_controller" {
  count = 1
  source  = "campaand/alb-ingress-controller/aws"
  version = "2.0.0"

  namespace = "dictionary-namespace"
  cluster_name = "cbd3324-eks-cluster"
}