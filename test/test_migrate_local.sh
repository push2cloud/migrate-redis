export fromService=7000
export toService=7001
export VCAP_SERVICES='{
  "redis": [
    {
      "name": "7000",
      "credentials": {
        "host": "localhost",
        "password": "foobar",
        "port": "7000"
      }
    },
    {
      "name": "7001",
      "credentials": {
        "host": "localhost",
        "password": "foobar",
        "port": "7001"
      }
    }
  ]
}'
export DEBUG=true

from='redis-cli -p 7000 -a foobar'
to='redis-cli -p 7001 -a foobar'

echo "preparing test data in local instances..."
${from} flushall
${to} flushall
${from} set 'key' 'value'
${from} set 'backslashes' 'hello\r\r\r\n\n\nworld'
${from} set 'multiline' "hello
world"
${from} set 'multiline2' ="hello\nworld"

echo "starting migration..."
./migrate.sh
echo "migration.sh RC: [$?]"

echo "verifing data..."
echo "key: [$(${to} get key)]"
echo "backslashes: [$(${to} get backslashes)]"
echo "multiline: [$(${to} get multiline)]"
echo "multiline2: [$(${to} get multiline2)]"
