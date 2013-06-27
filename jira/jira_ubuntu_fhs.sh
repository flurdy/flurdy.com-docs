#!/bin/bash

JIRAVERSION=4.0.1
DATETODAY=`date -I`

echo Installing java
sudo aptitude install sun-java6-jdk;
echo Choose java-6-sun
sudo update-alternatives --config java;
echo JAVA_HOME=/usr/lib/jvm/java-6-sun > /tmp/java.sh
echo export JAVA_HOME >> /tmp/java.sh
sudo mv /tmp/java.sh /etc/profile.d/java.sh
sudo chown root:root /etc/profile.d/java.sh
sudo chmod +x /etc/profile.d/java.sh

echo Downloading Jira
wget http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-enterprise-$JIRAVERSION-standalone.tar.gz

echo Extract and move Jira
tar xzf atlassian-jira-enterprise-$JIRAVERSION-standalone.tar.gz;
sudo mkdir /opt/atlassian;
sudo mv atlassian-jira-enterprise-$JIRAVERSION-standalone /opt/atlassian/jira-$JIRAVERSION
sudo ln -s /opt/atlassian/jira-$JIRAVERSION /opt/atlassian/jira

echo Adding jira user
sudo /usr/sbin/useradd --create-home --home-dir /usr/local/jira --shell /bin/bash jira;
sudo chown -R jira:jira /opt/atlassian/jira-$JIRAVERSION

echo Edit configuration and enter Jira home
sudo perl -pi -e '
	s%^(jira.home) =%$1 = /var/opt/atlassian/jira%
' /opt/atlassian/jira/atlassian-jira/WEB-INF/classes/jira-application.properties


echo Create folders for configuration and data
sudo mkdir -p /etc/opt/atlassian/jira;
sudo mkdir -p /var/opt/atlassian/jira;
sudo chown jira:jira /etc/opt/atlassian/jira /var/opt/atlassian/jira

echo Move logs
sudo mv /opt/atlassian/jira/logs /var/log/jira;
sudo ln -s /var/log/jira /opt/atlassian/jira/logs
sudo touch /var/log/jira/atlassian-jira.log;
sudo chown jira:jira /var/log/jira/atlassian-jira.log;
sudo ln -s /var/log/jira/atlassian-jira.log /opt/atlassian/jira/atlassian-jira.log;

echo Linking configurations
sudo ln -s /opt/atlassian/jira/atlassian-jira/WEB-INF/classes/jira-application.properties \
	/etc/opt/atlassian/jira/;
sudo ln -s /opt/atlassian/jira/atlassian-jira/WEB-INF/classes/log4j.properties \
 	/etc/opt/atlassian/jira/;
sudo mv  /opt/atlassian/jira/conf    /etc/opt/atlassian/jira/tomcat;
sudo ln -s /etc/opt/atlassian/jira/tomcat    /opt/atlassian/jira/conf

echo Moving the database
sudo mkdir -p /var/lib/hsqldb/jira;
sudo chown jira:jira /var/lib/hsqldb/jira;
sudo ln -s /var/lib/hsqldb/jira /opt/atlassian/jira/database

echo Moving non static tomcat files
sudo mkdir /var/opt/atlassian/jira-tomcat;
sudo mv /opt/atlassian/jira/work     /var/opt/atlassian/jira-tomcat/;
sudo mv /opt/atlassian/jira/temp     /var/opt/atlassian/jira-tomcat/;
sudo ln -s /var/opt/atlassian/jira-tomcat/work     /opt/atlassian/jira/;
sudo ln -s /var/opt/atlassian/jira-tomcat/temp	  /opt/atlassian/jira/


echo Creating Init script
echo "#!/bin/sh" > /tmp/jira.sh
echo "# Example Atlassian Standalone init script" >> /tmp/jira.sh
echo "" >> /tmp/jira.sh
echo "# Define some variables" >> /tmp/jira.sh
echo "# Name of app ( JIRA, Confluence, etc )" >> /tmp/jira.sh
echo "APP=JIRA" >> /tmp/jira.sh
echo "# Name of the user to run as" >> /tmp/jira.sh
echo "USER=jira" >> /tmp/jira.sh
echo "# Location of application bin directory" >> /tmp/jira.sh
echo "BIN=/opt/atlassian/jira/bin" >> /tmp/jira.sh
echo "# Location of Java JDK" >> /tmp/jira.sh
echo "export JAVA_HOME=/usr/lib/jvm/java-6-sun" >> /tmp/jira.sh
echo "" >> /tmp/jira.sh
echo "case \"\$1\" in" >> /tmp/jira.sh
echo "  # Start command" >> /tmp/jira.sh
echo "  start)" >> /tmp/jira.sh
echo "    echo \"Starting \$APP\"" >> /tmp/jira.sh
echo "    /bin/su -m \$USER -c \"\$BIN/startup.sh &> /dev/null\"" >> /tmp/jira.sh
echo "    ;;" >> /tmp/jira.sh
echo "  # Stop command" >> /tmp/jira.sh
echo "  stop)" >> /tmp/jira.sh
echo "    echo \"Stopping \$APP\"" >> /tmp/jira.sh
echo "    /bin/su -m \$USER -c \"\$BIN/shutdown.sh &> /dev/null\"" >> /tmp/jira.sh
echo "    echo \"\$APP stopped successfully\"" >> /tmp/jira.sh
echo "    ;;" >> /tmp/jira.sh
echo "  *)" >> /tmp/jira.sh
echo "    echo \"Usage: /etc/init.d/jira {start|stop}\"" >> /tmp/jira.sh
echo "    exit 1" >> /tmp/jira.sh
echo "    ;;" >> /tmp/jira.sh
echo "esac" >> /tmp/jira.sh
sudo mv /tmp/jira.sh /etc/init.d/jira
sudo chown root:root /etc/init.d/jira
sudo chmod 751 /etc/init.d/jira
echo Ignore the following LSB warnings...
sudo update-rc.d jira defaults

echo Backuping up
sudo tar cf jira.$DATETODAY.1.tar /etc/opt/atlassian/jira;
sudo tar rf jira.$DATETODAY.1.tar /var/opt/atlassian/jira;
sudo tar rf jira.$DATETODAY.1.tar /var/lib/hsqldb/jira;
sudo tar rf jira.$DATETODAY.1.tar /var/log/jira;
sudo gzip jira.$DATETODAY.1.tar;

echo You may now start Jira with "sudo /etc/init.d/jira start"

