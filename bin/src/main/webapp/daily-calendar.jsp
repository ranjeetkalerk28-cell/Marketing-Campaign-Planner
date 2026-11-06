<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List, java.util.Map, java.util.ArrayList, java.util.LinkedHashMap" %>
<%@ page import="java.time.*, java.time.format.*" %>
<%
    @SuppressWarnings("unchecked")
    List<Map<String,Object>> calTasks = (List<Map<String,Object>>) request.getAttribute("calTasks");
    if (calTasks == null) calTasks = new ArrayList<>();

    int    year      = (Integer) request.getAttribute("year");
    int    month     = (Integer) request.getAttribute("month");
    String prevMonth = (String)  request.getAttribute("prevMonth");
    String nextMonth = (String)  request.getAttribute("nextMonth");
    String ctx       = request.getContextPath();

    YearMonth ym        = YearMonth.of(year, month);
    int       daysInMon = ym.lengthOfMonth();
    LocalDate firstDay  = ym.atDay(1);
    int       startCol  = firstDay.getDayOfWeek().getValue() % 7; // Sun=0
    String    monthLabel = firstDay.format(DateTimeFormatter.ofPattern("MMMM yyyy"));
    LocalDate today     = LocalDate.now();

    // Build a day → tasks map for quick lookup
    Map<Integer, List<Map<String,Object>>> tasksByDay = new LinkedHashMap<>();
    for (int d = 1; d <= daysInMon; d++) tasksByDay.put(d, new ArrayList<>());
    for (Map<String,Object> task : calTasks) {
        java.sql.Date dl = (java.sql.Date) task.get("deadline");
        if (dl == null) continue;
        LocalDate ld = dl.toLocalDate();
        if (ld.getYear() == year && ld.getMonthValue() == month) {
            tasksByDay.get(ld.getDayOfMonth()).add(task);
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Task Calendar — <%= monthLabel %></title>
    <meta name="description" content="Task calendar showing task deadlines for <%= monthLabel %>.">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    <style>
        /* ── Calendar shell ─────────────────────────────── */
        .cal-nav {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 18px; flex-wrap: wrap; gap: 12px;
        }
        .cal-nav-title {
            font-family:'Outfit','Inter',sans-serif;
            font-size: 1.45rem; font-weight: 900; color: var(--text);
            letter-spacing: -0.03em;
        }
        .cal-nav-btns { display:flex; gap:8px; }

        /* Grid */
        .cal-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 4px;
        }
        .cal-header-cell {
            text-align: center; font-size: 0.68rem; font-weight: 700;
            letter-spacing: 0.08em; text-transform: uppercase;
            color: var(--text-muted); padding: 6px 0 10px;
        }
        .cal-day {
            min-height: 110px;
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 8px 6px 6px;
            position: relative;
            cursor: pointer;
            transition: box-shadow 0.15s, border-color 0.15s;
        }
        .cal-day:hover { box-shadow: 0 4px 18px rgba(99,102,241,0.15); border-color: rgba(99,102,241,0.35); }
        .cal-day.other-month { background: var(--bg); opacity: 0.4; pointer-events: none; }
        .cal-day.today {
            border-color: var(--primary);
            box-shadow: 0 0 0 2px rgba(99,102,241,0.28);
        }
        .cal-day.has-tasks { border-color: rgba(99,102,241,0.25); }

        .cal-day-num {
            font-size: 0.78rem; font-weight: 700; color: var(--text-muted);
            line-height: 1; margin-bottom: 5px;
        }
        .cal-day.today .cal-day-num {
            background: var(--primary); color: #fff;
            width: 22px; height: 22px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.72rem; margin-bottom: 5px;
        }

        /* Task pill inside cell */
        .task-pill {
            font-size: 0.60rem; font-weight: 600;
            padding: 2px 5px; border-radius: 4px;
            margin-bottom: 2px; line-height: 1.3;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
            display: block;
            cursor: pointer;
            text-decoration: none;
            transition: filter 0.15s, transform 0.12s;
        }
        .task-pill:hover { filter: brightness(1.08); transform: translateX(2px); }
        .task-pill.pending     { background: rgba(245,158,11,0.15); color: #B45309; border-left: 2px solid #F59E0B; }
        .task-pill.inprogress  { background: rgba(99,102,241,0.13); color: var(--primary-dark); border-left: 2px solid var(--primary); }
        .task-pill.completed   { background: rgba(16,185,129,0.13); color: #065F46; border-left: 2px solid #10B981; }
        .task-pill.more        { background: var(--border-light); color: var(--text-muted); border-left: 2px solid var(--border); cursor: default; }
        .task-pill.more:hover  { filter: none; transform: none; }

        /* ── Side panel popup ───────────────────────────── */
        .day-panel-overlay {
            position: fixed; inset: 0;
            background: rgba(0,0,0,0.35);
            z-index: 900;
            display: none; opacity: 0;
            transition: opacity 0.2s;
        }
        .day-panel-overlay.open { display: flex; opacity: 1; }

        .day-panel {
            position: fixed;
            top: 0; right: -420px; bottom: 0;
            width: 380px; max-width: 95vw;
            background: var(--bg-card);
            border-left: 1px solid var(--border);
            z-index: 901;
            overflow-y: auto;
            padding: 28px 24px;
            transition: right 0.28s cubic-bezier(0.22,1,0.36,1);
            box-shadow: -8px 0 32px rgba(0,0,0,0.18);
        }
        .day-panel.open { right: 0; }

        .day-panel-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 20px;
        }
        .day-panel-date {
            font-family:'Outfit','Inter',sans-serif;
            font-size: 1.3rem; font-weight: 900; color: var(--text);
            letter-spacing: -0.03em;
        }
        .day-panel-close {
            background: var(--border-light); border: none; border-radius: 8px;
            width: 32px; height: 32px; cursor: pointer;
            font-size: 1rem; color: var(--text-muted);
            display: flex; align-items: center; justify-content: center;
            transition: background 0.15s, color 0.15s;
        }
        .day-panel-close:hover { background: var(--danger); color: #fff; }

        .panel-task-card {
            background: var(--bg);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 14px;
            margin-bottom: 10px;
            transition: box-shadow 0.15s, border-color 0.15s;
            cursor: pointer;
        }
        .panel-task-card:hover { box-shadow: 0 4px 16px rgba(99,102,241,0.14); border-color: rgba(99,102,241,0.3); }
        .panel-task-title {
            font-size:0.90rem; font-weight:700; color:var(--primary);
            margin-bottom:5px; text-decoration:none;
            display:block;
        }
        .panel-task-title:hover { text-decoration:underline; }
        .panel-task-meta  { font-size:0.71rem; color:var(--text-muted); display:flex; flex-wrap:wrap; gap:8px; margin-bottom:8px; }
        .panel-task-actions { display:flex; gap:6px; flex-wrap:wrap; }

        /* Legend */
        .cal-legend {
            display: flex; flex-wrap: wrap; gap: 10px;
            margin-bottom: 16px; align-items: center;
        }
        .cal-legend-item {
            display: flex; align-items: center; gap: 6px;
            font-size: 0.72rem; font-weight: 600; color: var(--text-muted);
        }
        .cal-legend-dot { width:10px; height:10px; border-radius:3px; flex-shrink:0; }

        @media (max-width:768px) {
            .cal-day { min-height: 72px; }
            .task-pill { font-size: 0.56rem; }
            .day-panel { width: 90vw; }
        }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/includes/nav.jsp" %>

<div class="main-content">

    <header class="page-header">
        <div class="page-header-left">
            <h1>🗓 Task Calendar</h1>
            <p>Task deadlines for <%= monthLabel %></p>
        </div>
        <div class="page-header-right">
            <a href="<%= ctx %>/todaysTasks"
               class="btn btn-outline btn-sm" id="todaysTasksBtn">☀️ Today's Tasks</a>
            <a href="<%= ctx %>/calendar"
               class="btn btn-primary btn-sm" id="calTodayBtn">Today</a>
        </div>
    </header>


    <main class="content-area">

        <div class="breadcrumb">
            <a href="<%= ctx %>/dashboard">Dashboard</a>
            <span class="sep">›</span>
            <span>Task Calendar</span>
        </div>

        <!-- Month navigation -->
        <div class="cal-nav fade-up">
            <div class="cal-nav-title"><%= monthLabel %></div>
            <div class="cal-nav-btns">
                <a href="<%= ctx %>/calendar?month=<%= prevMonth %>"
                   class="btn btn-outline btn-sm" id="prevMonthBtn">← Prev</a>
                <a href="<%= ctx %>/calendar?month=<%= nextMonth %>"
                   class="btn btn-outline btn-sm" id="nextMonthBtn">Next →</a>
            </div>
        </div>

        <!-- Legend -->
        <div class="cal-legend fade-up" style="animation-delay:0.05s;">
            <span style="font-size:0.72rem;font-weight:700;color:var(--text-muted);margin-right:4px;">Status:</span>
            <div class="cal-legend-item"><div class="cal-legend-dot" style="background:#F59E0B;"></div><span>Pending</span></div>
            <div class="cal-legend-item"><div class="cal-legend-dot" style="background:var(--primary);"></div><span>In Progress</span></div>
            <div class="cal-legend-item"><div class="cal-legend-dot" style="background:#10B981;"></div><span>Completed</span></div>
        </div>

        <!-- Stats row -->
        <div class="stats-grid stagger" style="--cols:4; margin-bottom:18px;" id="dailyStatsRow">
            <%
                int totalThisMonth = calTasks.size();
                long pendingCnt  = calTasks.stream().filter(t->"Pending".equalsIgnoreCase((String)t.get("status"))).count();
                long inProgCnt   = calTasks.stream().filter(t->"In Progress".equalsIgnoreCase((String)t.get("status"))).count();
                long doneCnt     = calTasks.stream().filter(t->"Completed".equalsIgnoreCase((String)t.get("status"))).count();
            %>
            <div class="stat-card indigo fade-up" style="--delay:0.08s;">
                <div class="stat-top"><div class="stat-icon-pill">📋</div><span class="stat-trend">Month</span></div>
                <div class="stat-body"><div class="stat-value"><%= totalThisMonth %></div><div class="stat-label">Total Tasks</div></div>
            </div>
            <div class="stat-card amber fade-up" style="--delay:0.12s;">
                <div class="stat-top"><div class="stat-icon-pill">⏳</div><span class="stat-trend">Pending</span></div>
                <div class="stat-body"><div class="stat-value"><%= pendingCnt %></div><div class="stat-label">Pending</div></div>
            </div>
            <div class="stat-card purple fade-up" style="--delay:0.16s;">
                <div class="stat-top"><div class="stat-icon-pill">🔄</div><span class="stat-trend">Active</span></div>
                <div class="stat-body"><div class="stat-value"><%= inProgCnt %></div><div class="stat-label">In Progress</div></div>
            </div>
            <div class="stat-card green fade-up" style="--delay:0.20s;">
                <div class="stat-top"><div class="stat-icon-pill">✅</div><span class="stat-trend">Done</span></div>
                <div class="stat-body"><div class="stat-value"><%= doneCnt %></div><div class="stat-label">Completed</div></div>
            </div>
        </div>

        <!-- Calendar grid -->
        <div class="card fade-up" style="animation-delay:0.22s; padding:16px;">
            <div class="cal-grid">

                <!-- Headers -->
                <% String[] dayNames = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
                   for (String d : dayNames) { %>
                <div class="cal-header-cell"><%= d %></div>
                <% } %>

                <!-- Leading empty -->
                <% for (int i = 0; i < startCol; i++) { %>
                <div class="cal-day other-month"></div>
                <% } %>

                <!-- Day cells -->
                <%
                    for (int dayNum = 1; dayNum <= daysInMon; dayNum++) {
                        LocalDate cellDate = ym.atDay(dayNum);
                        boolean isToday    = cellDate.equals(today);
                        List<Map<String,Object>> dayTasks = tasksByDay.get(dayNum);
                        boolean hasTasks = !dayTasks.isEmpty();

                        // Build JSON for this day (for the popup panel)
                        StringBuilder jsonTasks = new StringBuilder("[");
                        for (int ti = 0; ti < dayTasks.size(); ti++) {
                            Map<String,Object> t = dayTasks.get(ti);
                            String title      = ((String) t.get("title")).replace("\\","\\\\").replace("\"","\\\"").replace("'","\\'");
                            String status     = ((String) t.get("status"));
                            String type_      = ((String) t.get("type")).replace("\"","\\\"");
                            String campName   = ((String) t.get("campaignName")).replace("\\","\\\\").replace("\"","\\\"");
                            double cost       = (double) t.get("cost");
                            int    taskId     = (int)    t.get("id");
                            int    campId     = (int)    t.get("campaignId");
                            if (ti > 0) jsonTasks.append(",");
                            jsonTasks.append("{")
                                .append("\"id\":").append(taskId).append(",")
                                .append("\"title\":\"").append(title).append("\",")
                                .append("\"status\":\"").append(status).append("\",")
                                .append("\"type\":\"").append(type_).append("\",")
                                .append("\"campName\":\"").append(campName).append("\",")
                                .append("\"cost\":").append(cost).append(",")
                                .append("\"campId\":").append(campId)
                                .append("}");
                        }
                        jsonTasks.append("]");

                        String dateLabel = cellDate.format(DateTimeFormatter.ofPattern("d MMM yyyy"));
                %>
                <div class="cal-day <%= isToday ? "today" : "" %> <%= hasTasks ? "has-tasks" : "" %>"
                     <%= hasTasks ? "onclick=\"openPanel('" + dateLabel + "', " + jsonTasks + ")\"" : "" %>>
                    <div class="cal-day-num"><%= dayNum %></div>
                    <%
                        int maxShow = 3;
                        for (int ti = 0; ti < Math.min(maxShow, dayTasks.size()); ti++) {
                            Map<String,Object> t = dayTasks.get(ti);
                            String status  = (String) t.get("status");
                            String pillCls = "Completed".equalsIgnoreCase(status) ? "completed"
                                           : "In Progress".equalsIgnoreCase(status) ? "inprogress" : "pending";
                            String titleTrunc = (String) t.get("title");
                            int pillTaskId = (int) t.get("id");
                    %>
                    <%-- Clickable pill: opens editTask, stops bubble so day-panel doesn't also open --%>
                    <a class="task-pill <%= pillCls %>"
                       href="<%= ctx %>/editTask?id=<%= pillTaskId %>"
                       title="Open: <%= titleTrunc %>"
                       onclick="event.stopPropagation();"><%= titleTrunc %></a>
                    <%  } %>
                    <%  if (dayTasks.size() > maxShow) { %>
                    <span class="task-pill more">+<%= dayTasks.size() - maxShow %> more</span>
                    <%  } %>
                </div>
                <% } %>

                <!-- Trailing empty -->
                <%
                    int totalCells   = startCol + daysInMon;
                    int trailingCells = (7 - (totalCells % 7)) % 7;
                    for (int i = 0; i < trailingCells; i++) {
                %>
                <div class="cal-day other-month"></div>
                <% } %>
            </div>
        </div>

        <!-- No tasks notice -->
        <% if (calTasks.isEmpty()) { %>
        <div class="empty-state fade-up" style="animation-delay:0.28s; padding:40px 20px; margin-top:16px;">
            <div class="empty-icon">🗓</div>
            <h3>No tasks due this month</h3>
            <p>No task deadlines fall in <%= monthLabel %>. Add tasks to campaigns to see them here.</p>
            <a href="<%= ctx %>/campaigns" class="btn btn-primary" id="calDailyGoCampaigns">📋 Go to Campaigns</a>
        </div>
        <% } %>

    </main>
</div>

<!-- ── Day side-panel ────────────────────────────────────────── -->
<div class="day-panel-overlay" id="panelOverlay" onclick="closePanel()"></div>
<div class="day-panel" id="dayPanel" role="dialog" aria-modal="true" aria-label="Tasks for selected day">

    <div class="day-panel-header">
        <div class="day-panel-date" id="panelDateLabel">—</div>
        <button class="day-panel-close" onclick="closePanel()" title="Close" id="closePanelBtn">✕</button>
    </div>

    <div id="panelTaskList"></div>
</div>

<div class="toast-container" id="toastContainer"></div>

<script>
var _ctx = '<%= ctx %>';

function openPanel(dateLabel, tasks) {
    document.getElementById('panelDateLabel').textContent = dateLabel;
    var list = document.getElementById('panelTaskList');
    list.innerHTML = '';

    if (!tasks || tasks.length === 0) {
        list.innerHTML = '<p style="color:var(--text-muted);font-size:0.85rem;">No tasks for this day.</p>';
    } else {
        /* Sub-header count */
        var sub = document.createElement('p');
        sub.style.cssText = 'font-size:0.72rem;color:var(--text-muted);margin-bottom:14px;';
        sub.textContent = tasks.length + ' task' + (tasks.length !== 1 ? 's' : '') + ' due — click a card to edit';
        list.appendChild(sub);

        tasks.forEach(function(t) {
            var statusCls = t.status === 'Completed' ? 'badge-completed'
                          : t.status === 'In Progress' ? 'badge-in-progress' : 'badge-pending';
            var editUrl = _ctx + '/editTask?id=' + t.id;
            var campUrl = _ctx + '/tasks?campaignId=' + t.campId;

            var card = document.createElement('div');
            card.className = 'panel-task-card';
            /* Whole card click → edit task */
            card.addEventListener('click', function(e) {
                if (!e.target.closest('a')) window.location = editUrl;
            });
            card.innerHTML =
                /* Clickable title */
                '<a class="panel-task-title" href="' + editUrl + '" id="panelTitle_' + t.id + '">' + escHtml(t.title) + '</a>' +
                '<div class="panel-task-meta">' +
                    '<span>📌 ' + escHtml(t.type) + '</span>' +
                    '<span>🏷 ' + escHtml(t.campName) + '</span>' +
                    '<span>💰 ₹' + t.cost.toLocaleString('en-IN', {maximumFractionDigits:2}) + '</span>' +
                '</div>' +
                '<div style="margin-bottom:10px;">' +
                    '<span class="badge ' + statusCls + '">' + escHtml(t.status) + '</span>' +
                '</div>' +
                '<div class="panel-task-actions">' +
                    '<a href="' + editUrl + '" class="btn btn-warning btn-sm" id="panelEdit_' + t.id + '">✏️ Edit Task</a>' +
                    '<a href="' + campUrl + '" class="btn btn-outline btn-sm" id="panelCamp_' + t.id + '">📋 All Campaign Tasks</a>' +
                '</div>';
            list.appendChild(card);
        });
    }

    document.getElementById('panelOverlay').classList.add('open');
    document.getElementById('dayPanel').classList.add('open');
    document.body.style.overflow = 'hidden';
}

function closePanel() {
    document.getElementById('panelOverlay').classList.remove('open');
    document.getElementById('dayPanel').classList.remove('open');
    document.body.style.overflow = '';
}

function escHtml(str) {
    var d = document.createElement('div');
    d.appendChild(document.createTextNode(str));
    return d.innerHTML;
}

// Close on Escape key
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closePanel();
});
</script>
</body>
</html>
