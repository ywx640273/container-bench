
podserver_name=`kubectl get pods --selector app=perf-test-1 -o jsonpath='{.items[0].metadata.name}'`
podserver_ip=`kubectl get pods --selector app=perf-test-1 -o jsonpath='{.items[0].status.podIP}'`
nodeserver_ip=`kubectl get pods --selector app=perf-test-1 -o jsonpath='{.items[0].status.hostIP}'`

podclent_name=`kubectl get pods --selector app=perf-test-2 -o jsonpath='{.items[0].metadata.name}'`
nodeclient_ip=`kubectl get pods --selector app=perf-test-2 -o jsonpath='{.items[0].status.hostIP}'`

python query_csv.py $prometheus_url $currentTimeStamp $nodeserver_ip
python query_csv.py $prometheus_url $currentTimeStamp $nodeclient_ip


kubectl exec $podserver_name -- sh -c '/home/paas/iperf -s &'
kubectl exec $podclient_name -- /home/paas/iperf -c $podserver_ip -P 10

python query_csv.py $prometheus_url $currentTimeStamp $nodeserver_ip
python query_csv.py $prometheus_url $currentTimeStamp $nodeclient_ip

kubectl exec $podserver_name -- pkill iperf

