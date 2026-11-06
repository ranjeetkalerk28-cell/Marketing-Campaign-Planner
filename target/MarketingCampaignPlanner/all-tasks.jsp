<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> allTasks  = (List<Map<String, Object>>) request.getAttribute("allTasks");
    @SuppressWarnings("unchecked")
    Map<String, Object>       taskStats = (Map<String, Object>)       request.getAttribute("taskStats");
    String ctx = request.getContextPath();

    if (allTasks  == null) allTasks  = java.util.Collections.emptyList();
    if (taskStats == null) taskStats = java.util.Collections.emptyMap();

    /* ── Unpack stats ────────────────────────────────────── */
    int    totalTasks     = taskStats.containsKey("totalTasks")     ? (int)    taskStats.get("totalTasks")     : 0;
    int    pending        = taskStats.containsKey("pending")        ? (int)    taskStats.get("pending")        : 0;
    int    inProgress     = taskStats.containsKey("inProgress")     ? (int)    taskStats.get("inProgress")     : 0;
    int    completed      = taskStats.containsKey("completed")      ? (int)    taskStats.get("completed")      : 0;
    double totalCost      = taskStats.containsKey("totalCost")      ? (double) taskStats.get("totalCost")      : 0.0;
    int    totalLeads     = taskStats.containsKey("totalLeads")     ? (int)    taskStats.get("totalLeads")     : 0;
    double cpl            = taskStats.containsKey("cpl")            ? (double) taskStats.get("cpl")            : 0.0;
    int    totalCampaigns = taskStats.containsKey("totalCampaigns") ? (int)    taskStats.get("totalCampaigns") : 0;

    int completePct  = totalTasks > 0 ? Math.round(100f * completed  / totalTasks) : 0;
    int inProgPct    = totalTasks > 0 ? Math.round(100f * inProgress / totalTasks) : 0;
    int pendingPct   = totalTasks > 0 ? Math.round(100f * pending    / totalTasks) : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>All Tasks — Marketing Campaign Planner</title>
    <meta name="description" content="Global task overview across all marketing campaigns.">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    <style>
        /* ── Page-specific extras ───────────────────────────── */

        /* CPL-style summary banner (reused from campaign dash) */
        .tasks-banner {
            border-radius: var(--r);
            padding: 26px 30px;
            margin-bottom: 22px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 24px;
            position: relative;
            overflow: hidden;
            background: linear-gradient(135deg, #4338CA 0%, #6D28D9 45%, #7C3AED 75%, #8B5CF6 100%);
            box-shadow: 0 10px 36px rgba(67,56,202,0.38);
            border: 1px solid rgba(255,255,255,0.08);
        }
        .tasks-banner::before {
            content: '';
            position: absolute;
            top: -80px; right: -60px;
            width: 280px; height: 280px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(255,255,255,0.10) 0%, transparent 70%);
            pointer-events: none;
        }
        .tasks-banner::after {
            content: '';
            position: absolute;
            bottom: -100px; left: 30%;
            width: 240px; height: 240px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(255,255,255,0.06) 0%, transparent 70%);
            pointer-events: none;
        }
        .tb-grid {
            position: absolute; inset: 0;
            background-image:
                linear-gradient(rgba(255,255,255,0.030) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255,255,255,0.030) 1px, transparent 1px);
            background-size: 30px 30px;
            pointer-events: none;
        }
        .tb-left, .tb-right { position: relative; z-index: 1; }
        .tb-eyebrow {
            font-size: 0.66rem; font-weight: 700; letter-spacing: 0.12em;
            text-transform: uppercase; color: rgba(255,255,255,0.65);
            margin-bottom: 8px; display: flex; align-items: center; gap: 7px;
        }
        .tb-eyebrow::before { content:''; width:12px; height:2px; background:rgba(255,255,255,0.4); border-radius:2px; }
        .tb-value {
            font-family: 'Outfit','Inter',sans-serif;
            font-size: 2.8rem; font-weight: 900; line-height:1;
            letter-spacing: -0.03em; color:#fff;
        }
        .tb-sub { font-size:0.78rem; opacity:0.60; margin-top:8px; font-style:italic; }
        .tb-divider { width:1px; background:rgba(255,255,255,0.12); align-self:stretch; flex-shrink:0; }
        .tb-stats { display:flex; gap:28px; flex-wrap:wrap; }
        .tb-stat-label { font-size:0.67rem; letter-spacing:0.08em; text-transform:uppercase; color:rgba(255,255,255,0.50); margin-bottom:4px; }
        .tb-stat-val { font-family:'Outfit','Inter',sans-serif; font-size:1.3rem; font-weight:800; color:#fff; letter-spacing:-0.02em; }

        /* Completion ring + breakdown container */
        .metrics-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-bottom: 22px;
        }

        .donut-card {
            background: var(--bg-card);
            border-radius: var(--r);
            padding: 22px;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            align-items: center;
            gap: 22px;
            flex-wrap: wrap;
        }

        .donut-wrap { position:relative; width:88px; height:88px; flex-shrink:0; }
        .donut-svg  { transform: rotate(-90deg); }
        .donut-bg   { fill:none; stroke:var(--border-light); stroke-width:10; }
        .donut-fill { fill:none; stroke-width:10; stroke-linecap:round; transition: stroke-dasharray 1.4s cubic-bezier(0.22,1,0.36,1); }
        .donut-label { position:absolute; inset:0; display:flex; flex-direction:column; align-items:center; justify-content:center; line-height:1.1; }
        .donut-pct  { font-family:'Outfit',sans-serif; font-size:1.2rem; font-weight:800; color:var(--text); letter-spacing:-0.03em; }
        .donut-sub  { font-size:0.54rem; color:var(--text-muted); font-weight:600; letter-spacing:0.05em; text-transform:uppercase; }

        .breakdown-list { flex:1; min-width:160px; display:flex; flex-direction:column; gap:10px; }
        .breakdown-row  { display:flex; align-items:center; gap:10px; }
        .breakdown-dot  { width:8px; height:8px; border-radius:50%; flex-shrink:0; }
        .breakdown-label{ font-size:0.76rem; color:var(--text-muted); font-weight:500; flex:1; }
        .breakdown-bar  { width:64px; height:4px; background:var(--border-light); border-radius:100px; overflow:hidden; flex-shrink:0; }
        .breakdown-bar-fill { height:100%; border-radius:100px; transition: width 1.2s cubic-bezier(0.22,1,0.36,1); }
        .breakdown-count{ font-family:'Outfit',sans-serif; font-size:0.88rem; font-weight:700; color:var(--text); }

        /* Cost card */
        .cost-card {
            background: var(--bg-card);
            border-radius: var(--r);
            padding: 22px;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .cost-card-title { font-size:0.78rem; font-weight:700; text-transform:uppercase; letter-spacing:0.07em; color:var(--text-muted); }
        .cost-grid { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
        .cost-item-label { font-size:0.69rem; color:var(--text-muted); font-weight:600; letter-spacing:0.05em; text-transform:uppercase; margin-bottom:4px; }
        .cost-item-val { font-family:'Outfit','Inter',sans-serif; font-size:1.45rem; font-weight:800; color:var(--text); letter-spacing:-0.025em; line-height:1; }
        .cost-item-sub { font-size:0.68rem; color:var(--text-muted); margin-top:2px; }

        /* Campaign name pill in table */
        .campaign-pill {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 3px 10px;
            border-radius: 7px;
            font-size: 0.70rem;
            font-weight: 600;
            background: var(--primary-xlight);
            color: var(--primary-dark);
            border: 1px solid rgba(99,102,241,0.18);
            white-space: nowrap;
            max-width: 160px;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        @media (max-width: 760px) {
            .metrics-row { grid-template-columns: 1fr; }
            .tb-divider  { display: none; }
            .tb-stats    { gap: 16px; }
        }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/includes/nav.jsp" %>

<div class="main-content">

    <header class="page-header">
        <div class="page-header-left">
            <h1>All Tasks</h1>
            <p>Global task view across <%= totalCampaigns %> campaign<%= totalCampaigns != 1 ? "s" : "" %></p>
        </div>
        <div class="page-header-right">
            <a href="<%= ctx %>/campaigns" class="btn btn-outline btn-sm" id="toCampaignsBtn">📋 Campaigns</a>
            <a href="<%= ctx %>/dashboard"  class="btn btn-primary btn-sm" id="toDashBtn">🏠 Dashboard</a>
        </div>
    </header>

    <main class="content-area">

        <div class="breadcrumb">
            <a href="<%= ctx %>/dashboard">Dashboard</a>
            <span class="sep">›</span>
            <span>All Tasks</span>
        </div>

        <!-- ══════════════════════════════════════════════════ -->
        <!--  PERFORMANCE OVERVIEW                              -->
        <!-- ══════════════════════════════════════════════════ -->

        <div class="section-header">
            <span class="section-title">Performance Overview</span>
            <div class="section-line"></div>
        </div>

        <!-- ── Stat Cards ─────────────────────────────────── -->
        <div class="stats-grid stagger">

            <div class="stat-card indigo fade-up" data-icon="📋">
                <div class="stat-top">
                    <div class="stat-icon-pill">📋</div>
                    <span class="stat-trend">All</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= totalTasks %>">0</div>
                    <div class="stat-label">Total Tasks</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;" data-w="100"></div>
                    </div>
                    <div class="stat-progress-label"><%= totalCampaigns %> campaign<%= totalCampaigns!=1?"s":"" %></div>
                </div>
            </div>

            <div class="stat-card amber fade-up" data-icon="🔄">
                <div class="stat-top">
                    <div class="stat-icon-pill">🔄</div>
                    <span class="stat-trend"><%= inProgPct %>%</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= inProgress %>">0</div>
                    <div class="stat-label">In Progress</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;background:linear-gradient(90deg,var(--warning),var(--amber));" data-w="<%= inProgPct %>"></div>
                    </div>
                    <div class="stat-progress-label"><%= inProgPct %>% of total</div>
                </div>
            </div>

            <div class="stat-card green fade-up" data-icon="✅">
                <div class="stat-top">
                    <div class="stat-icon-pill">✅</div>
                    <span class="stat-trend"><%= completePct %>%</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= completed %>">0</div>
                    <div class="stat-label">Completed</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;background:linear-gradient(90deg,var(--success),var(--teal));" data-w="<%= completePct %>"></div>
                    </div>
                    <div class="stat-progress-label"><%= completePct %>% done</div>
                </div>
            </div>

            <div class="stat-card purple fade-up" data-icon="⏳">
                <div class="stat-top">
                    <div class="stat-icon-pill">⏳</div>
                    <span class="stat-trend"><%= pendingPct %>%</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= pending %>">0</div>
                    <div class="stat-label">Pending</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;background:linear-gradient(90deg,var(--secondary),var(--rose));" data-w="<%= pendingPct %>"></div>
                    </div>
                    <div class="stat-progress-label"><%= pendingPct %>% of total</div>
                </div>
            </div>

            <div class="stat-card teal fade-up" data-icon="🎯">
                <div class="stat-top">
                    <div class="stat-icon-pill">🎯</div>
                    <span class="stat-trend">Leads</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= totalLeads %>">0</div>
                    <div class="stat-label">Total Leads</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;background:linear-gradient(90deg,var(--teal),var(--info));" data-w="<%= totalLeads > 0 ? 72 : 0 %>"></div>
                    </div>
                    <div class="stat-progress-label">Across all tasks</div>
                </div>
            </div>

            <div class="stat-card red fade-up" data-icon="💸">
                <div class="stat-top">
                    <div class="stat-icon-pill">💸</div>
                    <span class="stat-trend">Cost</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value num" style="font-size:1.5rem;">₹<%= String.format("%,.0f", totalCost) %></div>
                    <div class="stat-label">Total Task Cost</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;background:linear-gradient(90deg,var(--danger),var(--rose));" data-w="<%= totalCost > 0 ? 80 : 0 %>"></div>
                    </div>
                    <div class="stat-progress-label">Combined all campaigns</div>
                </div>
            </div>

        </div>

        <!-- ── CPL Banner ─────────────────────────────────── -->
        <div class="tasks-banner fade-up" style="animation-delay:0.28s;">
            <div class="tb-grid"></div>
            <div class="tb-left">
                <div class="tb-eyebrow">Cost Per Lead — All Tasks</div>
                <div class="tb-value">
                    <%= totalLeads > 0 ? "₹" + String.format("%,.2f", cpl) : "—" %>
                </div>
                <div class="tb-sub">
                    CPL = Total Task Cost ÷ Total Leads
                    <% if (totalLeads == 0) { %>&nbsp;<em>(no leads yet)</em><% } %>
                </div>
            </div>
            <div class="tb-divider"></div>
            <div class="tb-right">
                <div class="tb-stats">
                    <div>
                        <div class="tb-stat-label">Total Task Cost</div>
                        <div class="tb-stat-val">₹<%= String.format("%,.0f", totalCost) %></div>
                    </div>
                    <div>
                        <div class="tb-stat-label">Total Leads</div>
                        <div class="tb-stat-val"><%= totalLeads %></div>
                    </div>
                    <div>
                        <div class="tb-stat-label">Completion</div>
                        <div class="tb-stat-val"><%= completePct %>%</div>
                    </div>
                    <div>
                        <div class="tb-stat-label">Campaigns</div>
                        <div class="tb-stat-val"><%= totalCampaigns %></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ── Completion Donut + Cost Grid ─────────────── -->
        <div class="metrics-row fade-up" style="animation-delay:0.34s;">

            <!-- Donut ring + breakdown -->
            <div class="donut-card">
                <div class="donut-wrap">
                    <svg class="donut-svg" width="88" height="88" viewBox="0 0 88 88">
                        <circle class="donut-bg" cx="44" cy="44" r="33"/>
                        <circle class="donut-fill" cx="44" cy="44" r="33"
                                stroke="<%= completePct >= 75 ? "#10B981" : (completePct >= 40 ? "#6366F1" : "#F59E0B") %>"
                                stroke-dasharray="0 207.3"
                                data-pct="<%= completePct %>"/>
                    </svg>
                    <div class="donut-label">
                        <div class="donut-pct"><%= completePct %>%</div>
                        <div class="donut-sub">Done</div>
                    </div>
                </div>

                <div class="breakdown-list">
                    <div style="font-size:0.80rem;font-weight:700;color:var(--text);margin-bottom:2px;">Task Completion Rate</div>

                    <div class="breakdown-row">
                        <div class="breakdown-dot" style="background:var(--success);"></div>
                        <span class="breakdown-label">Completed</span>
                        <div class="breakdown-bar">
                            <div class="breakdown-bar-fill" style="width:0%;background:var(--success);" data-bw="<%= completePct %>"></div>
                        </div>
                        <span class="breakdown-count"><%= completed %></span>
                    </div>
                    <div class="breakdown-row">
                        <div class="breakdown-dot" style="background:var(--warning);"></div>
                        <span class="breakdown-label">In Progress</span>
                        <div class="breakdown-bar">
                            <div class="breakdown-bar-fill" style="width:0%;background:var(--warning);" data-bw="<%= inProgPct %>"></div>
                        </div>
                        <span class="breakdown-count"><%= inProgress %></span>
                    </div>
                    <div class="breakdown-row">
                        <div class="breakdown-dot" style="background:var(--secondary);"></div>
                        <span class="breakdown-label">Pending</span>
                        <div class="breakdown-bar">
                            <div class="breakdown-bar-fill" style="width:0%;background:var(--secondary);" data-bw="<%= pendingPct %>"></div>
                        </div>
                        <span class="breakdown-count"><%= pending %></span>
                    </div>
                    <div style="font-size:0.69rem;color:var(--text-muted);margin-top:2px;">
                        <%= totalTasks %> total &bull; <%= totalTasks - completed %> remaining
                    </div>
                </div>
            </div>

            <!-- Key metrics grid -->
            <div class="cost-card">
                <div class="cost-card-title">📊 Key Metrics</div>
                <div class="cost-grid">
                    <div>
                        <div class="cost-item-label">Total Task Cost</div>
                        <div class="cost-item-val">₹<%= String.format("%,.0f", totalCost) %></div>
                        <div class="cost-item-sub">Across all tasks</div>
                    </div>
                    <div>
                        <div class="cost-item-label">Leads Generated</div>
                        <div class="cost-item-val" style="color:var(--teal-dark);"><%= totalLeads %></div>
                        <div class="cost-item-sub">From all campaigns</div>
                    </div>
                    <div>
                        <div class="cost-item-label">Cost Per Lead</div>
                        <div class="cost-item-val" style="color:var(--primary);">
                            <%= totalLeads > 0 ? "₹" + String.format("%,.2f", cpl) : "—" %>
                        </div>
                        <div class="cost-item-sub">Task cost ÷ leads</div>
                    </div>
                    <div>
                        <div class="cost-item-label">Avg Cost / Task</div>
                        <div class="cost-item-val" style="color:var(--secondary);">
                            <%= totalTasks > 0 ? "₹" + String.format("%,.0f", totalCost / totalTasks) : "—" %>
                        </div>
                        <div class="cost-item-sub">Per task average</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ══════════════════════════════════════════════════ -->
        <!--  TASK TABLE                                        -->
        <!-- ══════════════════════════════════════════════════ -->

        <div class="section-header">
            <span class="section-title">All Tasks — Combined View</span>
            <div class="section-line"></div>
        </div>

        <!-- Toolbar -->
        <div class="toolbar" id="allTasksToolbar">
            <div class="search-wrap">
                <svg class="search-icon-svg" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.8">
                    <circle cx="9" cy="9" r="6"/><path d="M15 15l-3.5-3.5"/>
                </svg>
                <input type="text" class="search-input" id="allTaskSearch"
                       placeholder="Search tasks or campaigns…" aria-label="Search tasks">
            </div>

            <div class="filter-group">
                <span class="filter-label-icon">🎯</span>
                <select class="filter-select" id="allStatusFilter" aria-label="Filter by status">
                    <option value="">All Statuses</option>
                    <option value="Pending">Pending</option>
                    <option value="In Progress">In Progress</option>
                    <option value="Completed">Completed</option>
                </select>
                <span class="filter-arrow">▾</span>
            </div>

            <div class="filter-group">
                <span class="filter-label-icon">📌</span>
                <select class="filter-select" id="allTypeFilter" aria-label="Filter by type">
                    <option value="">All Types</option>
                    <option value="Design">Design</option>
                    <option value="Content">Content</option>
                    <option value="Launch">Launch</option>
                    <option value="Research">Research</option>
                    <option value="Analysis">Analysis</option>
                    <option value="Outreach">Outreach</option>
                    <option value="Other">Other</option>
                </select>
                <span class="filter-arrow">▾</span>
            </div>

            <div class="toolbar-count">
                <span id="visibleTaskCount"><%= allTasks.size() %></span> / <%= allTasks.size() %>
                task<%= allTasks.size() != 1 ? "s" : "" %>
            </div>
        </div>

        <!-- Table card -->
        <div class="card fade-up" style="animation-delay:0.16s;">
            <div class="card-header">
                <h3>🗂 All Tasks</h3>
                <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                    <% if (pending > 0) { %>
                    <span class="badge badge-pending"><%= pending %> pending</span>
                    <% } %>
                    <% if (inProgress > 0) { %>
                    <span class="badge badge-in-progress"><%= inProgress %> in progress</span>
                    <% } %>
                    <% if (completed > 0) { %>
                    <span class="badge badge-completed"><%= completed %> done</span>
                    <% } %>
                </div>
            </div>

            <% if (allTasks.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-icon">📋</div>
                <h3>No tasks yet</h3>
                <p>Tasks will appear here once you create campaigns and add tasks to them.</p>
                <a href="<%= ctx %>/campaigns" class="btn btn-primary" id="emptyGoToCampaignsBtn">📂 Go to Campaigns</a>
            </div>
            <% } else { %>
            <div class="table-wrapper">
                <table id="allTasksTable">
                    <thead>
                        <tr>
                            <th style="width:40px;">#</th>
                            <th>Task Title</th>
                            <th>Campaign</th>
                            <th>Type</th>
                            <th>Deadline</th>
                            <th style="text-align:right;">Cost (₹)</th>
                            <th>Status</th>
                            <th style="text-align:center;">🎯 Leads</th>
                            <th style="width:120px;">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="allTasksTbody">
                    <%
                        int rn = 1;
                        for (Map<String, Object> row : allTasks) {
                            String taskStatus  = (String) row.get("status");
                            String taskType    = (String) row.get("type");
                            String campName    = (String) row.get("campaignName");
                            int    taskId      = (int)    row.get("id");
                            int    campId      = (int)    row.get("campaignId");
                            Object deadlineObj = row.get("deadline");
                            double taskCost    = (double) row.get("cost");
                            int    leads       = (int)    row.get("leadsGenerated");

                            String tsBadge = "badge-pending";
                            if      ("In Progress".equalsIgnoreCase(taskStatus)) tsBadge = "badge-in-progress";
                            else if ("Completed".equalsIgnoreCase(taskStatus))   tsBadge = "badge-completed";

                            String safeName = ((String) row.get("title")).replace("'", "\\'");
                    %>
                        <tr class="at-row"
                            data-title="<%= ((String)row.get("title")).toLowerCase() %>"
                            data-campaign="<%= campName.toLowerCase() %>"
                            data-status="<%= taskStatus %>"
                            data-type="<%= taskType %>">
                            <td class="text-muted text-xs num" style="text-align:center;"><%= rn++ %></td>
                            <td class="col-name"><%= row.get("title") %></td>
                            <td>
                                <a href="<%= ctx %>/tasks?campaignId=<%= campId %>"
                                   class="campaign-pill" title="View campaign tasks">
                                    <%= campName %>
                                </a>
                            </td>
                            <td><span class="type-pill"><%= taskType %></span></td>
                            <td class="text-sm"><%= deadlineObj != null ? deadlineObj.toString() : "—" %></td>
                            <td style="text-align:right;font-variant-numeric:tabular-nums;font-weight:700;">
                                ₹<%= String.format("%,.2f", taskCost) %>
                            </td>
                            <td><span class="badge <%= tsBadge %>"><%= taskStatus %></span></td>
                            <td style="text-align:center;font-weight:800;font-family:'Outfit',sans-serif;color:var(--teal-dark);font-variant-numeric:tabular-nums;">
                                <%= leads %>
                            </td>
                            <td>
                                <div class="actions-cell">
                                    <a href="<%= ctx %>/editTask?id=<%= taskId %>"
                                       class="btn btn-warning btn-sm" title="Edit task"
                                       id="editBtn_<%= taskId %>">✏️ Edit</a>
                                    <a href="<%= ctx %>/deleteTask?id=<%= taskId %>&campaignId=<%= campId %>"
                                       class="btn btn-danger btn-sm" title="Delete task"
                                       id="delBtn_<%= taskId %>"
                                       onclick="return confirm('Delete task \'<%= safeName %>\'?')">🗑</a>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <div id="noTaskResults" class="empty-state" style="display:none;padding:36px 20px;">
                <div class="empty-icon" style="font-size:2.5rem;">🔍</div>
                <h3 style="font-size:1rem;">No matching tasks</h3>
                <p>Try adjusting your search or filters.</p>
            </div>

            <% } %>
        </div>

    </main>
</div>

<div class="toast-container" id="toastContainer"></div>

<script>
window.addEventListener('DOMContentLoaded', function() {

    /* ── Animate stat counters ── */
    function countUp(el, target, ms) {
        if (target === 0) return;
        var step = 16, inc = target / (ms / step), cur = 0;
        var t = setInterval(function() {
            cur += inc;
            if (cur >= target) { cur = target; clearInterval(t); }
            el.textContent = Math.round(cur);
        }, step);
    }
    document.querySelectorAll('.stat-value[data-count]').forEach(function(el) {
        countUp(el, parseInt(el.getAttribute('data-count'), 10) || 0, 900);
    });

    /* ── Progress bars ── */
    setTimeout(function() {
        document.querySelectorAll('[data-w]').forEach(function(el) {
            el.style.width = el.getAttribute('data-w') + '%';
        });
        document.querySelectorAll('[data-bw]').forEach(function(el) {
            el.style.width = el.getAttribute('data-bw') + '%';
        });
    }, 350);

    /* ── Donut ring ── */
    setTimeout(function() {
        var circle = document.querySelector('.donut-fill[data-pct]');
        if (!circle) return;
        var pct = parseInt(circle.getAttribute('data-pct'), 10) || 0;
        var circ = 2 * Math.PI * 33; /* r = 33 */
        circle.style.strokeDasharray = (pct / 100 * circ) + ' ' + ((1 - pct / 100) * circ);
    }, 400);

    /* ── Live search + filter ── */
    var search  = document.getElementById('allTaskSearch');
    var byStat  = document.getElementById('allStatusFilter');
    var byType  = document.getElementById('allTypeFilter');
    var tbody   = document.getElementById('allTasksTbody');
    var noRes   = document.getElementById('noTaskResults');
    var countEl = document.getElementById('visibleTaskCount');

    function filterAll() {
        if (!tbody) return;
        var q  = search ? search.value.toLowerCase() : '';
        var st = byStat ? byStat.value : '';
        var ty = byType ? byType.value : '';
        var n  = 0;
        tbody.querySelectorAll('.at-row').forEach(function(row) {
            var titleMatch    = row.getAttribute('data-title').includes(q);
            var campaignMatch = row.getAttribute('data-campaign').includes(q);
            var ok = (titleMatch || campaignMatch)
                  && (!st || row.getAttribute('data-status') === st)
                  && (!ty || row.getAttribute('data-type')   === ty);
            row.style.display = ok ? '' : 'none';
            if (ok) n++;
        });
        if (countEl) countEl.textContent = n;
        if (noRes)   noRes.style.display = n === 0 && tbody.children.length > 0 ? 'block' : 'none';
    }

    if (search) search.addEventListener('input',  filterAll);
    if (byStat) byStat.addEventListener('change', filterAll);
    if (byType) byType.addEventListener('change', filterAll);

    /* ── Responsive metrics row ── */
    function checkGrid() {
        var el = document.querySelector('.metrics-row');
        if (!el) return;
        el.style.gridTemplateColumns = window.innerWidth < 700 ? '1fr' : '1fr 1fr';
    }
    checkGrid();
    window.addEventListener('resize', checkGrid);
});
</script>

</body>
</html>
