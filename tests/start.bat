SET _mSettings_DMS_URL=http://211.119.153.251:8040
SET _mSettings_AGENT_URL=http://52.78.95.37:3000
REM SET PORT=3500

REM <- REM이 #과 같은 주석임. forever 설치가 되면 forever로. 안되면 node 로 돌리고 창을 띄워 놔 버림 댐
REM forever -m 5 main.js
node main.js
