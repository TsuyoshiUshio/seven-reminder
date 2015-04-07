FROM ruby:2.2.0

RUN apt-get update -qq && apt-get install -y build-essential

RUN apt-get install -y libsqlite3-dev sqlite3

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
RUN apt-get install -y libqt4-webkit libqt4-dev xvfb

# for a JS runtime
RUN apt-get install -y nodejs
   
RUN wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
RUN apt-get update
RUN apt-get autoremove -y libbison-dev
RUN apt-get install -y jenkins

# Time Zone
RUN cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime 
RUN echo "Asia/Tokyo" > /etc/timezone

EXPOSE 8080

ENTRYPOINT etc/init.d/jenkins start &&\
			sleep 5 &&\
			tail -f /var/log/jenkins/jenkins.log
