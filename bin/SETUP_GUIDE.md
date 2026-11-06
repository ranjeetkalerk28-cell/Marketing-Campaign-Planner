# 🚀 Setup Guide — Running on a New System

This guide walks you through setting up and running the **Marketing Campaign Planner** on any Windows/Linux/macOS machine from scratch.

---

## ✅ Step 1 — Install Required Software

Make sure all of the following are installed before proceeding.

### 1.1 Java JDK 11

- Download from: https://www.oracle.com/java/technologies/javase/jdk11-archive-downloads.html  
  *(or use OpenJDK: https://adoptium.net/)*
- After installing, verify:
  ```bash
  java -version
  ```
  Expected output: `java version "11.x.x"`

- Set `JAVA_HOME` environment variable:
  - **Windows:** `Control Panel → System → Advanced → Environment Variables`
    - Add: `JAVA_HOME = C:\Program Files\Java\jdk-11`
    - Append to `Path`: `%JAVA_HOME%\bin`
  - **Linux/macOS:**
    ```bash
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
    export PATH=$JAVA_HOME/bin:$PATH
    ```

---

### 1.2 Apache Maven 3.6+

- Download from: https://maven.apache.org/download.cgi
- Verify:
  ```bash
  mvn -version
  ```
  Expected output: `Apache Maven 3.x.x`

- Set `MAVEN_HOME` and add `bin/` to your `PATH` if not auto-detected.

---

### 1.3 MySQL 8.x

- Download from: https://dev.mysql.com/downloads/mysql/
- During installation:
  - Set a **root password** (remember it — you'll need it later)
  - Keep the default port: **3306**
- Verify MySQL is running:
  ```bash
  mysql -u root -p
  ```

---

### 1.4 Apache Tomcat 9.x

- Download from: https://tomcat.apache.org/download-90.cgi  
  *(Download the **zip/tar.gz** binary distribution)*
- Extract it to a memorable location, e.g.:
  - Windows: `C:\tomcat9`
  - Linux/macOS: `/opt/tomcat9`
- Verify the folder structure contains: `bin/`, `webapps/`, `conf/`

---

## ✅ Step 2 — Get the Project Files

Copy the entire `MarketingCampaignPlanner/` project folder onto the new machine.

Your folder should look like:
```
MarketingCampaignPlanner/
├── database/
│   └── schema.sql
├── src/
├── pom.xml
└── SETUP_GUIDE.md
```

---

## ✅ Step 3 — Set Up the Database

### 3.1 Open MySQL and Run the Schema

```bash
mysql -u root -p < path\to\MarketingCampaignPlanner\database\schema.sql
```

**Or** open MySQL Workbench / command line and run manually:

```bash
mysql -u root -p
```
```sql
SOURCE /full/path/to/MarketingCampaignPlanner/database/schema.sql;
```

This will:
- Create a database called `marketing_db`
- Create the `campaigns` and `tasks` tables
- Insert sample data automatically

### 3.2 Verify

```sql
USE marketing_db;
SHOW TABLES;
SELECT * FROM campaigns;
```

You should see 3 sample campaigns.

---

## ✅ Step 4 — Update the Database Credentials

Open this file in any text editor:

```
src/main/java/util/DBConnection.java
```

Update lines 16–17 with **your** MySQL username and password:

```java
private static final String USER     = "root";       // ← your MySQL username
private static final String PASSWORD = "your_pass";  // ← your MySQL password
```

> ⚠️ The default credentials in the file (`root` / `279279`) are specific to the original machine. You **must** change them to match your MySQL setup.

---

## ✅ Step 5 — Build the Project

Open a terminal/command prompt, navigate to the project folder, and run:

```bash
cd path\to\MarketingCampaignPlanner

mvn clean package
```

This will:
- Download all Maven dependencies (requires internet on first run)
- Compile all Java source files
- Package everything into a WAR file

After a successful build, you'll see:

```
BUILD SUCCESS
```

The WAR file will be at:
```
target/MarketingCampaignPlanner.war
```

---

## ✅ Step 6 — Deploy to Tomcat

### 6.1 Copy the WAR file

Copy `target/MarketingCampaignPlanner.war` into Tomcat's `webapps/` directory:

**Windows:**
```powershell
copy target\MarketingCampaignPlanner.war C:\tomcat9\webapps\
```

**Linux/macOS:**
```bash
cp target/MarketingCampaignPlanner.war /opt/tomcat9/webapps/
```

### 6.2 Start Tomcat

 **Windows:**
```cmd
C:\tomcat9\bin\startup.bat
```

**Linux/macOS:**
```bash
/opt/tomcat9/bin/startup.sh
```

Tomcat will auto-deploy the WAR. Watch the console for:
```
INFO: Deployment of web application archive [...] has finished
```

### 6.3 Stop Tomcat (when needed)

**Windows:** `shutdown.bat`  
**Linux/macOS:** `shutdown.sh`

---

## ✅ Step 7 — Open the Application

Open your browser and go to:

```
http://localhost:8080/MarketingCampaignPlanner/
```

You should be redirected to the **Dashboard** page. ✅

---

## 🔍 Troubleshooting

### ❌ `BUILD FAILURE` — Compilation errors
- Make sure your Java version is **exactly 11** (`java -version`)
- Ensure `JAVA_HOME` is set correctly

### ❌ `Communications link failure` — DB connection error
- Make sure MySQL is **running**: `net start MySQL` (Windows) or `sudo systemctl start mysql` (Linux)
- Double-check the credentials in `DBConnection.java`
- Confirm the database `marketing_db` exists: `SHOW DATABASES;`

### ❌ `HTTP 404` — Page not found
- Check that the WAR is inside `webapps/` and Tomcat has been restarted
- Make sure Tomcat is running on port **8080** (default)

### ❌ `ClassNotFoundException: com.mysql.cj.jdbc.Driver`
- Run `mvn clean package` again — the MySQL connector JAR must be bundled inside the WAR
- Check `target/MarketingCampaignPlanner/WEB-INF/lib/` for `mysql-connector-java-*.jar`

### ❌ Port 8080 already in use
- Change Tomcat's port in `conf/server.xml`:
  ```xml
  <Connector port="8081" protocol="HTTP/1.1" ... />
  ```
  Then access the app at `http://localhost:8081/MarketingCampaignPlanner/`

---

## 📋 Quick Checklist

```
[ ] Java JDK 11 installed and JAVA_HOME set
[ ] Maven installed and on PATH
[ ] MySQL 8 installed and running
[ ] Tomcat 9 downloaded and extracted
[ ] schema.sql executed (marketing_db created)
[ ] DBConnection.java updated with your MySQL password
[ ] mvn clean package ran successfully (BUILD SUCCESS)
[ ] WAR file copied to Tomcat's webapps/
[ ] Tomcat started
[ ] http://localhost:8080/MarketingCampaignPlanner/ opens in browser
```

---

*For questions about the project structure or features, refer to `README.md`.*
