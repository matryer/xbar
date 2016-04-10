# Long running plugins

## Streaming through stdout

Output `~~~` from long running scripts to render everything above it and since the last `~~~`. Example:

```bash
#!/usr/bin/env sh
COUNTER=0
count() {
  COUNTER=$((COUNTER+1));
  echo "$COUNTER"
  echo '---'
  echo "Some menu entry"
  echo "~~~"
}
while [ $COUNTER -lt 3 ]; do
  count
  sleep 1
done
```

The output looks like this:

    1
    ---
    Some menu entry
    ~~~
    2
    ---
    Some menu entry
    ~~~
    3
    ---
    Some menu entry
    ~~~
