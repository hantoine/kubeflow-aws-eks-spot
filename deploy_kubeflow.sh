read -p "Enter a name for the cluster: " cluster_name
read -p "Enter Kubeflow admin e-mail: " admin_email
read -p "Enter Kubeflow admin password: " admin_password

mkdir $cluster_name && cd $cluster_name

sed "s/<name>/$cluster_name/" ../cluster_template.yaml > cluster.yaml
eksctl create cluster -f cluster.yaml

sed "s/<cluster_name>/$cluster_name/ ; s/<admin_password>/$admin_password/ ; s/<admin_email>/$admin_email/" ../kfctl_aws_template.yaml > kfctl_aws.yaml
kfctl apply -f kfctl_aws.yaml

sleep 5
kubectl get pod -n kubeflow --no-headers | grep -v Running >> /dev/null
while [ "$?" == "0" ] ; do
    sleep 5
    kubectl get pod -n kubeflow --no-headers | grep -v Running >> /dev/null
done
kubectl get ingress -n istio-system
echo "To delete the cluster, use 'eksctl delete cluster ${cluster_name}'"
