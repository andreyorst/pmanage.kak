# pmanage.kak

This plugin is aimed to make it easier to run and manage background processes
from Kakoune editor. It provides three commands to start and stop processes:

- `pstart <command>`: Starts `command` as background process, and create FIFO
  buffer for that process named after process PID.
- `pstop <PID>`: delete process buffer and send `SIGTERM` signal to process.
- `pkill <PID>`: delete process buffer and send `SIGKILL` signal to process.

You can track all processes with `pmanage_process_list` option.

## Installation

### With [`plug.kak`](https://github.com/andreyorst/plug.kak)
Add this to your `kakrc`:

```sh
plug "andreyorst/pmanage.kak"
```

Restart Kakoune or re-source your `kakrc` and call `plug-install` command.

### Without plugin manager
Clone this repository to your `autoload` directory, or source `pmanage.kak` file
from your `kakrc`.
