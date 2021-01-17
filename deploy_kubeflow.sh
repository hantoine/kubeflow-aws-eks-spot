read -p "Enter a name for the cluster: " cluster_name
read -p "Enter Kubeflow admin e-mail: " admin_email
read -p "Enter Kubeflow admin password: " admin_password

# Kubeflow assumes the current folder's name is the name of the cluster when configuring the ALB
mkdir $cluster_name && cd $cluster_name

sed "s/<name>/$cluster_name/" ../m5spot_template.yaml > m5spot.yaml
eksctl create cluster -f m5spot.yaml

sed "s/<admin_password>/$admin_password/ ; s/<admin_email>/$admin_email/" ../kfctl_aws_template.yaml > kfctl_aws.yaml
kfctl apply -V -f kfctl_aws.yaml

sleep 5
kubectl get pod -n kubeflow --no-headers | grep -v Running >> /dev/null
while [ "$?" == "0" ] ; do
    sleep 5
    kubectl get pod -n kubeflow --no-headers | grep -v Running >> /dev/null
done
kubectl get ingress -n istio-system
echo "To delete the cluster, use 'eksctl delete cluster ${cluster_name}'"
