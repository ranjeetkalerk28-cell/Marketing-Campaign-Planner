# 📣 Marketing Campaign Planner

A full-stack Java web application for managing marketing campaigns, tasks, and lead generation metrics. Built with a classic **MVC architecture** using Servlets, JSP, JDBC, and MySQL — packaged as a WAR and deployed on Apache Tomcat.

---

## ✨ Features

| Area | Details |
|---|---|
| **Campaign Management** | Create, view, edit, and delete campaigns with budget, type, status, and date tracking |
| **Task Management** | Full CRUD for tasks linked to campaigns; track cost, deadline, type, and status |
| **Dashboard** | Aggregated KPIs — total campaigns, active campaigns, total budget, total leads, and Cost Per Lead (CPL) |
| **All-Tasks View** | Unified task board across every campaign with live search and status/type filtering |
| **Campaign Task List** | Per-campaign task breakdown with progress bars and performance stats |
| **Lead Sync** | Campaign `leads` column auto-synced from the sum of child task `leads_generated` |
| **Animated UI** | Dark-themed, glassmorphism-styled interface with animated stat cards and donut charts |

---

## 🏗️ Architecture

```
MVC Pattern
├── Model      → Campaign.java, Task.java
├── View       → JSP pages (dashboard, campaign-list, task-list, all-tasks, forms)
├── Controller → CampaignServlet.java, TaskServlet.java
└── DAO        → CampaignDAO.java, TaskDAO.java  (JDBC → MySQL)
```

---

## 📁 Project Structure

```
MarketingCampaignPlanner/
├── database/
│   └── schema.sql                    # DB creation script + sample data
├── src/
│   └── main/
│       ├── java/
│       │   ├── dao/
│       │   │   ├── CampaignDAO.java  # CRUD for campaigns
│       │   │   └── TaskDAO.java      # CRUD for tasks
│       │   ├── model/
│       │   │   ├── Campaign.java     # Campaign POJO
│       │   │   └── Task.java         # Task POJO
│       │   ├── servlet/
│       │   │   ├── CampaignServlet.java  # Handles /campaign/*
│       │   │   └── TaskServlet.java      # Handles /task/*
│       │   └── util/
│       │       └── DBConnection.java  # Singleton JDBC connection helper
│       └── webapp/
│           ├── WEB-INF/
│           │   └── web.xml           # Servlet mappings
│           ├── css/                  # Stylesheets
│           ├── index.jsp             # Entry redirect
│           ├── dashboard.jsp         # Main KPI dashboard
│           ├── campaign-list.jsp     # All campaigns overview
│           ├── add-campaign.jsp      # New campaign form
│           ├── edit-campaign.jsp     # Edit campaign form
│           ├── task-list.jsp         # Per-campaign task view
│           ├── all-tasks.jsp         # Global task board
│           ├── add-task.jsp          # New task form
│           └── edit-task.jsp         # Edit task form
├── pom.xml                           # Maven build descriptor
└── sync-to-tomcat.ps1               # PowerShell deploy helper script
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Language | Java 11 |
| Web Framework | Jakarta EE (Servlet API 4.0.1 / JSP 2.3.3) |
| Template Engine | JSP + JSTL 1.2 |
| Database | MySQL 8 |
| JDBC Driver | MySQL Connector/J 8.0.33 |
| Build Tool | Maven 3 (`maven-war-plugin 3.3.2`) |
| Server | Apache Tomcat 9 |
| Packaging | WAR |

---

## ⚙️ Prerequisites

- Java JDK 11+
- Apache Maven 3.6+
- Apache Tomcat 9.x
- MySQL 8.x

---

## 🚀 Setup & Deployment

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd "adv jp project/MarketingCampaignPlanner"
```

### 2. Set Up the Database

```bash
mysql -u root -p < database/schema.sql
```

This creates the `marketing_db` database, the `campaigns` and `tasks` tables, and loads sample data.

### 3. Configure the Database Connection

Edit `src/main/java/util/DBConnection.java` and update these constants to match your MySQL credentials:

```java
private static final String URL  = "jdbc:mysql://localhost:3306/marketing_db";
private static final String USER = "root";
private static final String PASS = "your_password";
```

### 4. Build the WAR

```bash
mvn clean package
```

The WAR file will be generated at:
```
target/MarketingCampaignPlanner.war
```

### 5. Deploy to Tomcat

**Option A — Manual:**
Copy the WAR to Tomcat's `webapps/` folder:
```bash
cp target/MarketingCampaignPlanner.war /path/to/tomcat/webapps/
```

**Option B — PowerShell helper (Windows):**
```powershell
.\sync-to-tomcat.ps1
```

### 6. Access the Application

```
http://localhost:8080/MarketingCampaignPlanner/
```

---

## 🗄️ Database Schema

```sql
-- campaigns
CREATE TABLE campaigns (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100)  NOT NULL,
    description TEXT,
    start_date  DATE,
    end_date    DATE,
    budget      DOUBLE        DEFAULT 0,
    type        VARCHAR(50),             -- e.g. Email, Ads, Social Media
    status      VARCHAR(20)   DEFAULT 'Planned',
    leads       INT           DEFAULT 0  -- synced from SUM(tasks.leads_generated)
);

-- tasks
CREATE TABLE tasks (
    id               INT PRIMARY KEY AUTO_INCREMENT,
    campaign_id      INT         NOT NULL,
    title            VARCHAR(100),
    type             VARCHAR(50),         -- e.g. Design, Launch, Research
    deadline         DATE,
    cost             DOUBLE      DEFAULT 0,
    status           VARCHAR(20) DEFAULT 'Pending',
    leads_generated  INT         DEFAULT 0,
    FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE CASCADE
);
```

---

## 🌐 URL Routes

| Method | URL Pattern | Action |
|---|---|---|
| GET | `/campaign/list` | List all campaigns |
| GET | `/campaign/add` | Show add-campaign form |
| POST | `/campaign/add` | Create a new campaign |
| GET | `/campaign/edit?id={id}` | Show edit form |
| POST | `/campaign/edit` | Update campaign |
| GET | `/campaign/delete?id={id}` | Delete campaign |
| GET | `/task/list?campaignId={id}` | List tasks for a campaign |
| GET | `/task/all` | List all tasks across campaigns |
| GET | `/task/add?campaignId={id}` | Show add-task form |
| POST | `/task/add` | Create a new task |
| GET | `/task/edit?id={id}` | Show edit-task form |
| POST | `/task/edit` | Update task |
| GET | `/task/delete?id={id}` | Delete task |
| GET | `/` | Redirect to dashboard |

---

## 📊 Key Metrics Tracked

- **Total Budget** — sum of all campaign budgets
- **Total Leads** — sum of all `leads_generated` across tasks
- **Cost Per Lead (CPL)** — `Total Budget ÷ Total Leads`
- **Active Campaigns** — campaigns with status `Active`
- **Task Completion Rate** — per-campaign percentage of completed tasks

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m "Add your feature"`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

This project is for academic/educational purposes as part of an Advanced Java Programming course.
