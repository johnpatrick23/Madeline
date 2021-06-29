
# Madeline

Script for monitoring Guacamole Service

## Installation
Use the madeline installation [Madeline](https://github.com/johnpatrick23/Madeline/blob/main/install/madeline.sh) to install Madeline.

```bash
sudo wget https://raw.githubusercontent.com/johnpatrick23/Madeline/main/install/madeline.sh -O - | bash
```

## Configuration
Go to config.yml to set your custom configuration
```bash
sudo nano /etc/Madeline/config/config.yml
```

```yml
SENDGRID:
  EMAIL_APIKEY: sendgridapikey
  EMAIL_FROM: verifiedemail@example.com
  EMAIL_TO:
    - emailto1@example.com
    - emailto2@example.com
  EMAIL_CC:
    - emailcc1@example.com
    - emailcc2@example.com
```
## Setting up service
Reload the daemon
```bash
sudo systemctl daemon-reload
```
Start madeline.service
```bash
sudo systemctl start madeline.service
```
Enable madeline.service as start up
```bash
sudo systemctl enable madeline.service
```
## Additional commands
Stop madeline.service
```bash
sudo systemctl start madeline.service
```
Check status of madeline.service
```bash
sudo systemctl status madeline.service
```
Restart of madeline.service
```bash
sudo systemctl restart madeline.service
```

## License
[MIT](https://choosealicense.com/licenses/mit/)
