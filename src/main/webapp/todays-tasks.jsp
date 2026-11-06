<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List, java.util.Map, java.util.ArrayList" %>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeFormatter" %>
<%
    @SuppressWarnings("unchecked")
    List<Map<String,Object>> todaysTasks =
        (List<Map<String,Object>>) request.getAttribute("todaysTasks");
    if (todaysTasks == null) todaysTasks = new ArrayList<>();

    String ctx = request.getContextPath();

    LocalDate today     = LocalDate.now();
    String    todayStr  = today.format(DateTimeFormatter.ofPattern("EEEE, d MMMM yyyy"));
    String    calMonth  = today.format(DateTimeFormatter.ofPattern("yyyy-MM"));

    // ── Stats ──────────────────────────────────────────────────────
    int total     = todaysTasks.size();
    int pending   = 0, inProgress = 0, completed = 0;
    double totalCost = 0;
    for (Map<String,Object> t : todaysTasks) {
        String st = (String) t.get("status");
        if      ("Pending".equalsIgnoreCase(st))     pending++;
        else if ("In Progress".equalsIgnoreCase(st)) inProgress++;
        else if ("Completed".equalsIgnoreCase(st))   completed++;
        totalCost += (double) t.get("cost");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Today's Tasks — <%= today %></title>
    <meta name="description" content="All marketing tasks due today, <%= todayStr %>.">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    <style>
        /* ── Today banner ────────────────────────────────── */
        .today-banner {
            border-radius: var(--r);
            padding: 28px 32px;
            margin-bottom: 24px;
            position: relative;
            overflow: hidden;
            background: linear-gradient(135deg, #0F172A 0%, #1E1B4B 40%, #312E81 75%, #4338CA 100%);
            box-shadow: 0 12px 40px rgba(67,56,202,0.40);
            border: 1px solid rgba(255,255,255,0.08);
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 20px;
        }
        .today-banner::before {
            content: '';
            position: absolute; top: -60px; right: -40px;
            width: 260px; height: 260px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(129,140,248,0.20) 0%, transparent 70%);
            pointer-events: none;
        }
        .today-banner::after {
            content: '📅';
            position: absolute; bottom: -10px; right: 24px;
            font-size: 6rem; opacity: 0.06; pointer-events: none;
            line-height: 1;
        }
        .today-banner-grid {
            position: absolute; inset: 0;
            background-image:
                linear-gradient(rgba(255,255,255,0.025) 1px, transparent 1px),
                linear-gradient(90deg,rgba(255,255,255,0.025) 1px, transparent 1px);
            background-size: 28px 28px;
            pointer-events: none;
        }
        .today-banner-left { position: relative; z-index: 1; }
        .today-banner-eyebrow {
            font-size: 0.65rem; font-weight: 700; letter-spacing: 0.12em;
            text-transform: uppercase; color: rgba(255,255,255,0.55);
            margin-bottom: 6px; display: flex; align-items: center; gap: 8px;
        }
        .today-banner-eyebrow::before {
            content:''; width:14px; height:2px;
            background: rgba(255,255,255,0.4); border-radius:2px;
        }
        .today-banner-date {
            font-family: 'Outfit','Inter',sans-serif;
            font-size: 1.9rem; font-weight: 900; color: #fff;
            letter-spacing: -0.04em; line-height: 1.1;
        }
        .today-banner-sub { font-size: 0.80rem; color: rgba(255,255,255,0.55); margin-top: 6px; }

        .today-banner-right { position: relative; z-index: 1; display: flex; gap: 24px; }
        .tb-mini { text-align: center; }
        .tb-mini-val {
            font-family:'Outfit','Inter',sans-serif;
            font-size: 1.6rem; font-weight: 900; color: #fff;
            letter-spacing: -0.03em; line-height: 1;
        }
        .tb-mini-label { font-size: 0.62rem; color: rgba(255,255,255,0.50); font-weight: 600;
                         letter-spacing: 0.07em; text-transform: uppercase; margin-top: 3px; }

        /* ── Priority indicator ───────────────────────────── */
        .priority-dot {
            width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0;
            box-shadow: 0 0 0 3px rgba(0,0,0,0.08);
        }
        .dot-pending    { background: #F59E0B; animation: pulse-amber 2s infinite; }
        .dot-inprogress { background: #6366F1; animation: pulse-indigo 2s infinite; }
        .dot-completed  { background: #10B981; }
        @keyframes pulse-amber  { 0%,100%{box-shadow:0 0 0 0 rgba(245,158,11,0.5)}  50%{box-shadow:0 0 0 5px rgba(245,158,11,0);} }
        @keyframes pulse-indigo { 0%,100%{box-shadow:0 0 0 0 rgba(99,102,241,0.5)}  50%{box-shadow:0 0 0 5px rgba(99,102,241,0);} }

        /* ── Task cards ──────────────────────────────────── */
        .tasks-today-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 14px;
            margin-top: 4px;
        }
        .today-task-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 18px 20px;
            cursor: pointer;
            transition: box-shadow 0.18s, border-color 0.18s, transform 0.15s;
            position: relative;
            overflow: hidden;
            text-decoration: none;
            display: block;
        }
        .today-task-card::before {
            content: '';
            position: absolute;
            left: 0; top: 0; bottom: 0;
            width: 4px;
            border-radius: 14px 0 0 14px;
        }
        .today-task-card.pending::before    { background: #F59E0B; }
        .today-task-card.inprogress::before { background: #6366F1; }
        .today-task-card.completed::before  { background: #10B981; }
        .today-task-card:hover {
            box-shadow: 0 6px 24px rgba(99,102,241,0.16);
            border-color: rgba(99,102,241,0.35);
            transform: translateY(-2px);
        }
        .today-task-card.completed:hover {
            border-color: rgba(16,185,129,0.35);
            box-shadow: 0 6px 24px rgba(16,185,129,0.14);
        }

        .ttc-top {
            display: flex; align-items: flex-start;
            justify-content: space-between; gap: 10px;
            margin-bottom: 10px;
        }
        .ttc-title {
            font-size: 0.96rem; font-weight: 800; color: var(--text);
            line-height: 1.3; flex: 1;
        }
        .ttc-meta {
            display: flex; flex-wrap: wrap; gap: 8px;
            margin-bottom: 12px;
        }
        .ttc-meta-item {
            display: flex; align-items: center; gap: 4px;
            font-size: 0.70rem; font-weight: 600;
            color: var(--text-muted); background: var(--bg);
            padding: 3px 8px; border-radius: 6px;
            border: 1px solid var(--border);
        }
        .ttc-actions {
            display: flex; gap: 8px; flex-wrap: wrap;
            margin-top: 12px; padding-top: 12px;
            border-top: 1px solid var(--border);
        }

        /* Empty state */
        .today-empty {
            text-align: center; padding: 64px 24px;
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: var(--r);
        }
        .today-empty-icon { font-size: 4rem; margin-bottom: 16px; }
        .today-empty h3 { font-size: 1.2rem; font-weight: 800; color: var(--text); margin-bottom: 8px; }
        .today-empty p  { color: var(--text-muted); font-size: 0.88rem; max-width: 380px; margin: 0 auto 20px; }

        /* Section tabs */
        .status-section { margin-bottom: 32px; }
        .status-section-header {
            display: flex; align-items: center; gap: 10px;
            margin-bottom: 14px;
        }
        .status-section-label {
            font-size: 0.78rem; font-weight: 800; letter-spacing: 0.06em;
            text-transform: uppercase;
        }
        .status-section-count {
            font-family: 'Outfit',sans-serif;
            font-size: 0.72rem; font-weight: 700;
            padding: 2px 8px; border-radius: 100px;
            background: var(--border-light); color: var(--text-muted);
        }
        .status-section-line { flex:1; height:1px; background:var(--border); }

        @media (max-width: 640px) {
            .today-banner-date { font-size: 1.4rem; }
            .tasks-today-grid  { grid-template-columns: 1fr; }
            .today-banner-right { gap: 16px; }
        }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/includes/nav.jsp" %>

<div class="main-content">

    <header class="page-header">
        <div class="page-header-left">
            <h1>☀️ Today's Tasks</h1>
            <p><%= todayStr %></p>
        </div>
        <div class="page-header-right">
            <a href="<%= ctx %>/calendar?month=<%= calMonth %>"
               class="btn btn-outline btn-sm" id="viewCalendarBtn">🗓 Calendar</a>
            <a href="<%= ctx %>/allTasks"
               class="btn btn-primary btn-sm" id="allTasksBtn">🗂 All Tasks</a>
        </div>
    </header>

    <main class="content-area">

        <div class="breadcrumb">
            <a href="<%= ctx %>/dashboard">Dashboard</a>
            <span class="sep">›</span>
            <span>Today's Tasks</span>
        </div>

        <!-- ── Today Banner ──────────────────────────────────────── -->
        <div class="today-banner fade-up">
            <div class="today-banner-grid"></div>
            <div class="today-banner-left">
                <div class="today-banner-eyebrow">Today's Deadline</div>
                <div class="today-banner-date"><%= todayStr %></div>
                <div class="today-banner-sub">
                    <%= total == 0 ? "No tasks due today — you're all clear!" :
                        total + " task" + (total != 1 ? "s" : "") + " due today" %>
                </div>
            </div>
            <% if (total > 0) { %>
            <div class="today-banner-right">
                <div class="tb-mini">
                    <div class="tb-mini-val"><%= total %></div>
                    <div class="tb-mini-label">Total</div>
                </div>
                <div class="tb-mini">
                    <div class="tb-mini-val" style="color:#FCD34D;"><%= pending %></div>
                    <div class="tb-mini-label">Pending</div>
                </div>
                <div class="tb-mini">
                    <div class="tb-mini-val" style="color:#A5B4FC;"><%= inProgress %></div>
                    <div class="tb-mini-label">In Progress</div>
                </div>
                <div class="tb-mini">
                    <div class="tb-mini-val" style="color:#6EE7B7;"><%= completed %></div>
                    <div class="tb-mini-label">Done</div>
                </div>
            </div>
            <% } %>
        </div>

        <% if (total == 0) { %>
        <!-- ── Empty State ──────────────────────────────────────── -->
        <div class="today-empty fade-up" style="animation-delay:0.10s;">
            <div class="today-empty-icon">🎉</div>
            <h3>All clear for today!</h3>
            <p>No tasks have a deadline of <%= todayStr %>. Check the calendar for upcoming deadlines.</p>
            <div style="display:flex;gap:10px;justify-content:center;flex-wrap:wrap;">
                <a href="<%= ctx %>/calendar?month=<%= calMonth %>" class="btn btn-primary" id="emptyCalBtn">🗓 View Calendar</a>
                <a href="<%= ctx %>/allTasks" class="btn btn-outline" id="emptyAllBtn">🗂 All Tasks</a>
            </div>
        </div>

        <% } else { %>

        <!-- ── Stat cards ───────────────────────────────────── -->
        <div class="stats-grid stagger fade-up" style="animation-delay:0.10s;">
            <div class="stat-card indigo">
                <div class="stat-top"><div class="stat-icon-pill">📋</div><span class="stat-trend">Today</span></div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= total %>">0</div>
                    <div class="stat-label">Due Today</div>
                </div>
            </div>
            <div class="stat-card amber">
                <div class="stat-top"><div class="stat-icon-pill">⏳</div><span class="stat-trend"><%= total > 0 ? Math.round(100f*pending/total) : 0 %>%</span></div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= pending %>">0</div>
                    <div class="stat-label">Pending</div>
                </div>
            </div>
            <div class="stat-card purple">
                <div class="stat-top"><div class="stat-icon-pill">🔄</div><span class="stat-trend"><%= total > 0 ? Math.round(100f*inProgress/total) : 0 %>%</span></div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= inProgress %>">0</div>
                    <div class="stat-label">In Progress</div>
                </div>
            </div>
            <div class="stat-card green">
                <div class="stat-top"><div class="stat-icon-pill">✅</div><span class="stat-trend"><%= total > 0 ? Math.round(100f*completed/total) : 0 %>%</span></div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= completed %>">0</div>
                    <div class="stat-label">Completed</div>
                </div>
            </div>
        </div>

        <%-- ── Pending section ──────────────────────────────────── --%>
        <% if (pending > 0) { %>
        <div class="status-section fade-up" style="animation-delay:0.18s;">
            <div class="status-section-header">
                <div class="priority-dot dot-pending"></div>
                <span class="status-section-label" style="color:#B45309;">Pending</span>
                <span class="status-section-count"><%= pending %></span>
                <div class="status-section-line"></div>
            </div>
            <div class="tasks-today-grid">
                <%
                    for (Map<String,Object> t : todaysTasks) {
                        if (!"Pending".equalsIgnoreCase((String)t.get("status"))) continue;
                        int    tid      = (int)    t.get("id");
                        int    campId   = (int)    t.get("campaignId");
                        String title_   = (String) t.get("title");
                        String type_    = (String) t.get("type");
                        String campName = (String) t.get("campaignName");
                        double cost     = (double) t.get("cost");
                        int    leads    = (int)    t.get("leadsGenerated");
                %>
                <a class="today-task-card pending"
                   href="<%= ctx %>/editTask?id=<%= tid %>"
                   id="todayCard_<%= tid %>">
                    <div class="ttc-top">
                        <div class="ttc-title"><%= title_ %></div>
                        <div class="priority-dot dot-pending" style="margin-top:4px;"></div>
                    </div>
                    <div class="ttc-meta">
                        <span class="ttc-meta-item">📌 <%= type_ %></span>
                        <span class="ttc-meta-item">🏷 <%= campName %></span>
                        <span class="ttc-meta-item">💰 ₹<%= String.format("%,.0f", cost) %></span>
                        <% if (leads > 0) { %><span class="ttc-meta-item">🎯 <%= leads %> leads</span><% } %>
                    </div>
                    <span class="badge badge-pending">Pending</span>
                    <div class="ttc-actions" onclick="event.stopPropagation()">
                        <a href="<%= ctx %>/editTask?id=<%= tid %>" class="btn btn-warning btn-sm" id="editPending_<%= tid %>">✏️ Edit</a>
                        <a href="<%= ctx %>/tasks?campaignId=<%= campId %>" class="btn btn-outline btn-sm" id="campPending_<%= tid %>">📋 Campaign</a>
                    </div>
                </a>
                <% } %>
            </div>
        </div>
        <% } %>

        <%-- ── In Progress section ──────────────────────────────── --%>
        <% if (inProgress > 0) { %>
        <div class="status-section fade-up" style="animation-delay:0.24s;">
            <div class="status-section-header">
                <div class="priority-dot dot-inprogress"></div>
                <span class="status-section-label" style="color:var(--primary-dark);">In Progress</span>
                <span class="status-section-count"><%= inProgress %></span>
                <div class="status-section-line"></div>
            </div>
            <div class="tasks-today-grid">
                <%
                    for (Map<String,Object> t : todaysTasks) {
                        if (!"In Progress".equalsIgnoreCase((String)t.get("status"))) continue;
                        int    tid      = (int)    t.get("id");
                        int    campId   = (int)    t.get("campaignId");
                        String title_   = (String) t.get("title");
                        String type_    = (String) t.get("type");
                        String campName = (String) t.get("campaignName");
                        double cost     = (double) t.get("cost");
                        int    leads    = (int)    t.get("leadsGenerated");
                %>
                <a class="today-task-card inprogress"
                   href="<%= ctx %>/editTask?id=<%= tid %>"
                   id="todayCard_<%= tid %>">
                    <div class="ttc-top">
                        <div class="ttc-title"><%= title_ %></div>
                        <div class="priority-dot dot-inprogress" style="margin-top:4px;"></div>
                    </div>
                    <div class="ttc-meta">
                        <span class="ttc-meta-item">📌 <%= type_ %></span>
                        <span class="ttc-meta-item">🏷 <%= campName %></span>
                        <span class="ttc-meta-item">💰 ₹<%= String.format("%,.0f", cost) %></span>
                        <% if (leads > 0) { %><span class="ttc-meta-item">🎯 <%= leads %> leads</span><% } %>
                    </div>
                    <span class="badge badge-in-progress">In Progress</span>
                    <div class="ttc-actions" onclick="event.stopPropagation()">
                        <a href="<%= ctx %>/editTask?id=<%= tid %>" class="btn btn-warning btn-sm" id="editInProg_<%= tid %>">✏️ Edit</a>
                        <a href="<%= ctx %>/tasks?campaignId=<%= campId %>" class="btn btn-outline btn-sm" id="campInProg_<%= tid %>">📋 Campaign</a>
                    </div>
                </a>
                <% } %>
            </div>
        </div>
        <% } %>

        <%-- ── Completed section ─────────────────────────────────── --%>
        <% if (completed > 0) { %>
        <div class="status-section fade-up" style="animation-delay:0.30s;">
            <div class="status-section-header">
                <div class="priority-dot dot-completed"></div>
                <span class="status-section-label" style="color:#065F46;">Completed</span>
                <span class="status-section-count"><%= completed %></span>
                <div class="status-section-line"></div>
            </div>
            <div class="tasks-today-grid">
                <%
                    for (Map<String,Object> t : todaysTasks) {
                        if (!"Completed".equalsIgnoreCase((String)t.get("status"))) continue;
                        int    tid      = (int)    t.get("id");
                        int    campId   = (int)    t.get("campaignId");
                        String title_   = (String) t.get("title");
                        String type_    = (String) t.get("type");
                        String campName = (String) t.get("campaignName");
                        double cost     = (double) t.get("cost");
                        int    leads    = (int)    t.get("leadsGenerated");
                %>
                <a class="today-task-card completed"
                   href="<%= ctx %>/editTask?id=<%= tid %>"
                   id="todayCard_<%= tid %>">
                    <div class="ttc-top">
                        <div class="ttc-title" style="color:var(--text-muted);text-decoration:line-through;text-decoration-color:rgba(0,0,0,0.2);"><%= title_ %></div>
                        <div class="priority-dot dot-completed" style="margin-top:4px;"></div>
                    </div>
                    <div class="ttc-meta">
                        <span class="ttc-meta-item">📌 <%= type_ %></span>
                        <span class="ttc-meta-item">🏷 <%= campName %></span>
                        <span class="ttc-meta-item">💰 ₹<%= String.format("%,.0f", cost) %></span>
                        <% if (leads > 0) { %><span class="ttc-meta-item">🎯 <%= leads %> leads</span><% } %>
                    </div>
                    <span class="badge badge-completed">✅ Completed</span>
                    <div class="ttc-actions" onclick="event.stopPropagation()">
                        <a href="<%= ctx %>/editTask?id=<%= tid %>" class="btn btn-outline btn-sm" id="editDone_<%= tid %>">✏️ Edit</a>
                        <a href="<%= ctx %>/tasks?campaignId=<%= campId %>" class="btn btn-outline btn-sm" id="campDone_<%= tid %>">📋 Campaign</a>
                    </div>
                </a>
                <% } %>
            </div>
        </div>
        <% } %>

        <% } /* end total > 0 */ %>

    </main>
</div>

<div class="toast-container" id="toastContainer"></div>

<script>
window.addEventListener('DOMContentLoaded', function () {
    /* Count-up for stat values */
    document.querySelectorAll('.stat-value[data-count]').forEach(function (el) {
        var target = parseInt(el.getAttribute('data-count'), 10) || 0;
        if (target === 0) return;
        var step = 16, inc = target / (800 / step), cur = 0;
        var t = setInterval(function () {
            cur += inc;
            if (cur >= target) { cur = target; clearInterval(t); }
            el.textContent = Math.round(cur);
        }, step);
    });

    /* Auto-refresh every 5 min so "today" stays current */
    setTimeout(function () { window.location.reload(); }, 5 * 60 * 1000);
});
</script>
</body>
</html>
