# CI/CD Pipeline Documentation for JAR Deployment to EC2

## 1. Architecture Flow
GitHub (Source Code)
│
▼
Jenkins (Build & Orchestrate)
├── Maven Build
├── SonarQube Code Analysis
├── OWASP Dependency Check
├── Docker Build & Push to Docker Hub
├── Trivy Image Scan
└── Deploy to EC2 (App Server)

---

## 2. EC2 Servers Setup

| Purpose       | EC2 Type | OS           | Storage | Inbound Ports                 |
|---------------|----------|--------------|---------|-------------------------------|
| Jenkins       | t3.medium| Ubuntu 22.04 | 15 GB   | 8080 (Jenkins), 22 (SSH)      |
| SonarQube     | t3.medium| Ubuntu 22.04 | 15 GB   | 9000 (SonarQube), 5432 (DB), 22 |
| App Server    | t3.micro | Ubuntu 22.04 | 10 GB   | 8090 (App), 22 (SSH)          |

---

## 3. Prerequisites and Configuration

### A. Jenkins Server

**Install Packages:**
```bash
sudo apt update
sudo apt install openjdk-21-jdk maven docker.io git unzip curl -y
```
**Install Jenkins:**
```bash
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y

**start Jenkins:**
sudo systemctl start jenkins
sudo systemctl enable jenkins
```
**Install Trivy:**
```bash
sudo apt install wget -y
wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_0.50.1_Linux-64bit.deb
sudo dpkg -i trivy_0.50.1_Linux-64bit.deb
```
**Install OWASP Dependency Check:**
```bash
wget https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.0/dependency-check-8.4.0-release.zip
unzip dependency-check-8.4.0-release.zip -d /opt/dependency-check
```
**Install SonarQube:**
```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y openjdk-17-jdk
java -version
# install PostgreSQL
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" /etc/apt/sources.list.d/pgdg.list'
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo apt install postgresql postgresql-contrib -y
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo systemctl status postgresql
psql --version
# switch to Postgre user
sudo -i -u postgres
createuser ddsonar
# login into PostgreSQL
psql
# Set a password for the ddsonar user. Use a strong password in place of my_strong_password.
ALTER USER [Created_user_name] WITH ENCRYPTED password 'my_strong_password';
# example
ALTER USER ddsonar WITH ENCRYPTED password 'mwd#2%#!!#%rgs';
# Create a SonarQube database and set the owner to ddsonar.
CREATE DATABASE [database_name] OWNER [Created_user_name];
# example
CREATE DATABASE ddsonarqube OWNER ddsonar;
# Grant all the privileges on the ddsonarqube database to the ddsonar user.
GRANT ALL PRIVILEGES ON DATABASE ddsonarqube to ddsonar;
#  Let's check the created database.
\l
# To check the created database user
\du
# Exit PostgreSQL.
\q
# Return to your non-root sudo user account.
exit
# download and Install Sonarqube
sudo apt install zip -y
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.0.0.68432.zip
sudo unzip sonarqube-10.0.0.68432.zip
sudo mv sonarqube-10.0.0.68432 sonarqube
sudo mv sonarqube /opt/
# Add SonarQube Group and User
sudo groupadd ddsonar
sudo useradd -d /opt/sonarqube -g ddsonar ddsonar
sudo chown ddsonar:ddsonar /opt/sonarqube -R
```
** Configure SonarQube:**

