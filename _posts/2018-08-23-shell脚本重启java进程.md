process_name=$1

echo "${process_name}"

ps -ef | grep ${process_name} | grep -v grep | awk '{print $2}' | xargs kill -9

nohup java -jar ${process_name} &
