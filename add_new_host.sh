
#!/usr/local/bin/zsh

echo "-------------------- Create new host --------------------"

# Check if the First argument is set and not empty
if [ -z $1 ];
	then
	echo "ServerName / ServerAlias shouldn't be empty ! add argument 1 please";
	exit;
 else
  SERVERNAME=$1
 fi

# Check if the second argument is set and not empty
if [ -z $2 ];
	then
	echo "DocumentRoot shouldn't be empty ! add argument 2 please";
	exit;
elif [ ! -d "$2" ]
then
	echo "DocumentRoot $2 is not a valid Directory";
	exit;
 else
  SERVERNAME=$1
 fi

DOCUMENTROOT=$2

VHOSTS_DIR="/private/etc/apache2/vhosts/"
# If the vhosts doesn't exist create it.
if [ ! -d "$VHOSTS_DIR" ]; then
   sudo mkdir $VHOSTS_DIR
    # Add Include /private/etc/apache2/vhosts/*.conf to /etc/apache2/httpd.conf.
   echo "--------------------Add Include /private/etc/apache2/vhosts/*.conf to /etc/apache2/httpd.conf --------------------"
   sudo $SHELL -c 'echo "Include '${VHOSTS_DIR}'*.conf" >> /etc/apache2/httpd.conf'
fi

CONFIG_FILE="${VHOSTS_DIR}${SERVERNAME}.conf"
if [ -f  CONFIG_FILE ]; then
	echo "The config  file $CONFIG_FILE already exist try with another Host name";
	exit;
	else
     echo "-------------------- Creating Config File $CONFIG_FILE --------------------"
echo "-------------------- Coping Config into File $CONFIG_FILE --------------------"

# Add Config to file
sudo  printf '<VirtualHost *:80>
    ServerAdmin admin@'$SERVERNAME'
    ServerName  '$SERVERNAME'
    ServerAlias '$SERVERNAME'
    DocumentRoot '$DOCUMENTROOT'
    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>
<Directory '$DOCUMENTROOT'>
        Options Indexes FollowSymLinks
        AllowOverride all
        Require all granted
</Directory>'  > $CONFIG_FILE

 if [ $? != 0 ]; then
   echo "We Coping config into file Something goes wrong please try later"
   exit;
   else
   	     echo "--------------------  Config copied  to File $CONFIG_FILE successfully  --------------------"
 fi
	 if [ $? != 0 ]; then
       echo "We can't create $CONFIG_FILE Something goes wrong please try later"
       exit;
       else
       	  echo "--------------------  File $CONFIG_FILE Created ! --------------------"
     fi
fi


echo "--------------------  Adding new host to /etc/hosts  \127.0.0.1	$SERVERNAME\ --------------------"

 sudo $SHELL -c 'echo "127.0.0.1       '$SERVERNAME'" >> /etc/hosts'

 if [ $? != 0 ]; then
   echo "Something goes wrong please add 127.0.0.1	$SERVERNAME to /etc/hosts manually"
   else
   	 echo "--------------------  New host $SERVERNAME successfully added to /etc/hosts  --------------------"
 fi

 echo "-------------------- Restarting Apache services to take effect \sudo apachectl restart\  --------------------"

 sudo apachectl restart

  if [ $? != 0 ]; then
   echo "Something goes wrong please when Restarting apache2 services please rerun \sudo apachectl restart\ "
   else
   	 echo "--------------------   Apache2 services restart  successfully --------------------"
     echo "--------------------   Enjoy happy navigation try the new site by navigate to  $SERVERNAME :1 --------------------"
 fi
