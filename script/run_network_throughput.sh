
podserver_name=`kubectl get pods --selector app=perf-test-1 -o jsonpath='{.items[0].metadata.name}'`
podserver_ip=`kubectl get pods --selector app=perf-test-1 -o jsonpath='{.items[0].status.podIP}'`
nodeserver_ip=`kubectl get pods --selector app=perf-test-1 -o jsonpath='{.items[0].status.hostIP}'`

podclient_name=`kubectl get pods --selector app=perf-test-2 -o jsonpath='{.items[0].metadata.name}'`
nodeclient_ip=`kubectl get pods --selector app=perf-test-2 -o jsonpath='{.items[0].status.hostIP}'`

if [[ -z "${FAST}" ]]; then
currentTimeStamp=`date +%s.%2N`
sleep 60
python query_csv.py $prometheus_url $currentTimeStamp $nodeserver_ip
python query_csv.py $prometheus_url $currentTimeStamp $nodeclient_ip
fi

currentTimeStamp=`date +%s.%2N`
kubectl exec $podserver_name -- sh -c '/home/paas/iperf -s >/log.iperf 2>&1 &'
kubectl exec $podclient_name -- /home/paas/iperf -c $podserver_ip -P 10 -t 120

if [[ -z "${FAST}" ]]; then
python query_csv.py $prometheus_url $currentTimeStamp $nodeserver_ip
python query_csv.py $prometheus_url $currentTimeStamp $nodeclient_ip
fi

kubectl exec $podserver_name -- sh -c 'pkill iperf; cat /log.iperf'

