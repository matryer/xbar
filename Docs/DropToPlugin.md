# Drop to plugin

Requires adding [metadata](README.md#metadata) for the accepted types.

## Example

`open`s paths and URLs dropped on the plugin.

```bash
#!/bin/bash

# <bitbar.droptypes>filenames,public.url</bitbar.droptypes>

if [ "$1" = "-filenames" ]; then
  shift
  open "$@"
  exit
fi

if [ "$1" = "-public.url" ]; then
  open "$2"
  exit
fi

echo "Drop here"
```
