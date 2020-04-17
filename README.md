# KERBEROS.**IO**

Fork of [kerberos-io/docker](https://github.com/kerberos-io/docker).

I created this fork to automate the web username/password setup. I wanted to deploy these containers quickly without any user interaction. For some reason I am getting a bunch of kernel crash dumps that eventually fill up the hard drive. With this setup, I can now recreate the container and destroy the image without any additional configuration.

## Use docker run

After you've installed docker, you can open a command prompt and type in following command. This will pull the kerberos image and make the web interface available on port 80 and the livestream on port 8889. You can give the container a custom name using the **--name** property.

To auto-configure the web setup, add the USERNAME and PASSWORD environment variables. If not provided, you will need to configure the username/password after you log in.
```
docker run --name camera1 -p 80:80 -p 8889:8889 -d kerberos/kerberos -e USERNAME='exampleuser' -e PASSWORD='examplepass'
docker run --name camera2 -p 81:80 -p 8890:8889 -d kerberos/kerberos -e USERNAME='exampleuser' -e PASSWORD='examplepass'
docker run --name camera3 -p 82:80 -p 8891:8889 -d kerberos/kerberos -e USERNAME='exampleuser' -e PASSWORD='examplepass'
```

## Use docker-compose

```
version: '3.5'
services:
  baby_cam:
    image: chuckcharlie/kerberos-auto-web:latest
    container_name: baby_cam
    ports:
      - "<port1>:80"
      - "<port2>:8889"
    volumes:
      - <path to scripts directory>:/etc/opt/kerberosio/scripts
      - <path to capture directory>:/etc/opt/kerberosio/capture
      - <path to config directory>:/etc/opt/kerberosio/config
    environment:
      USERNAME: "username"
      PASSWORD: "password"
    restart: unless-stopped
```
