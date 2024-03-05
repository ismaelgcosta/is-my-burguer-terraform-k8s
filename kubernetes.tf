resource "kubectl_manifest" "is-my-burguer-api-namespace" {
  depends_on = [
    data.aws_eks_cluster.cluster,
    module.eks.node_security_group_id,
    module.eks.node_security_group_arn,
    module.eks.cluster_security_group_id,
    module.eks.cluster_security_group_arn,
    module.eks.access_entries,
    module.eks.cluster_primary_security_group_id
  ]
  yaml_body = <<YAML
apiVersion: apps/v1
kind: Namespace
apiVersion: v1
metadata:
  name: is-my-burguer-api
  namespace: is-my-burguer-api
  labels:
    name: is-my-burguer-api
    app: is-my-burguer-api
YAML
}

resource "kubectl_manifest" "is-my-burguer-api-deployment" {
  depends_on = [
    data.aws_eks_cluster.cluster,
    kubernetes_secret.is-my-burguer-db,
    kubectl_manifest.is-my-burguer-api-namespace
  ]
  yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: is-my-burguer-api
  namespace: is-my-burguer-api
  labels:
    name: is-my-burguer-api
    app: is-my-burguer-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: is-my-burguer-api
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: is-my-burguer-api
    spec:
      containers:
        - name: is-my-burguer-api
          resources:
            limits:
              cpu: "1"
              memory: "300Mi"
            requests:
              cpu: "300m"
              memory: "300Mi"
          env:
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: is-my-burguer-db
                  key: password
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: is-my-burguer-db
                  key: username
            - name: POSTGRES_HOST
              valueFrom:
                secretKeyRef:
                  name: is-my-burguer-db
                  key: host
          image: docker.io/ismaelgcosta/is-my-burguer-app:is-my-burguer-api-2.0.2
          ports:
            - containerPort: 8080
      restartPolicy: Always
status: {}
YAML
}

resource "kubectl_manifest" "is-my-burguer-api-load-balancer" {
  depends_on = [
    data.aws_eks_cluster.cluster,
    kubectl_manifest.is-my-burguer-api-deployment,
    kubectl_manifest.is-my-burguer-api-namespace
  ]
  yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  name: is-my-burguer-api-loadbalancer
  namespace: is-my-burguer-api
spec:
  type: LoadBalancer
  selector:
    app: is-my-burguer-api
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 8080
      nodePort: 31080
    - name: https
      port: 443
      targetPort: 80
YAML
}


resource "kubectl_manifest" "is-my-burguer-api-hpa" {
  depends_on = [
    data.aws_eks_cluster.cluster,
    kubectl_manifest.is-my-burguer-api-deployment,
    kubectl_manifest.is-my-burguer-api-load-balancer,
    kubectl_manifest.is-my-burguer-api-namespace
  ]
  yaml_body = <<YAML
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: is-my-burguer-api-hpa
  namespace: is-my-burguer-api
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: is-my-burguer-api
    namespace: is-my-burguer-api
  minReplicas: 2
  maxReplicas: 4
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 0 # para forçar o kubernets a zerar a janela de tempo e escalar imediatamente
    scaleUp:
      stabilizationWindowSeconds: 0 # para forçar o kubernets a zerar a janela de tempo e escalar imediatamente
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 1 # para forçar o kubernets escalar com 1% de cpu
status:
  observedGeneration: 0
  lastScaleTime: 
  currentReplicas: 0
  desiredReplicas: 2
  currentMetrics:
  - type: Resource
    resource:
      name: cpu
YAML
}


resource "kubernetes_secret" "is-my-burguer-db" {
  depends_on = [
    kubectl_manifest.is-my-burguer-api-namespace
  ]

  metadata {
    name      = "is-my-burguer-db"
    namespace = kubectl_manifest.is-my-burguer-api-namespace.name
  }

  data = {
    host = "${data.terraform_remote_state.is-my-burguer-postgres.outputs.database_endpoint}",
    username = "${var.POSTGRES_USER}",
    password = "${var.POSTGRES_PASSWORD}"
  }

  type = "kubernetes.io/basic-auth"

}