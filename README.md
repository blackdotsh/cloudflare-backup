cloudflare-backup
=================

A bash script that checks if the website is online. If it isn't, switch to the failover IP using Cloudflare's API
<br>

- Make sure you edit the variables in the beginning of the script.
- You'll need tmux/screen/nohup so this will run even though you've logged out of your machine.
- A file called results.txt will be written, so make sure your working directory doesn't have a file with that name. Alternatively, you can edit to code to do whatever fits you best.
