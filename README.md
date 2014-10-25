# SeniorProject

## Members
- Hardy Thrower
- Brandon Worl
- Nolan Burfield

## Set Up Process
1. Clone repository from GitHub
2. Install RVM, mySQL, project gems, and nodejs
  - sudo apt-get install curl
  - \curl -sSL https://get.rvm.io | bash
  - source /home/<user>/.rvm/scripts/rvm
  - rvm install ruby-2.1.2
  - sudo apt-get install mysql-server
  - sudo apt-get install libmysqlclient-dev
  - bundle install
  - sudo apt-get install nodejs
3. Set up rails database config file
  - cp config/database.yml.example config/database.yml
4. Create database named "submit_development" and user named "submit" with password "password"
  - mysql -u root -p
  - CREATE USER 'submit'@'localhost' IDENTIFIED BY 'password';
  - CREATE DATABASE submit_development;
  - GRANT ALL ON submit_development.* TO 'submit'@'localhost';
  - exit
5. Create database tables
  - rake db:migrate
6. Make sure everything works
  - Visit localhost:3000 in web browser to verify everything works

## To Do
- Create new CSS for screens past login and registration
- Test uploading of files to database
- Start working on various views within the app
